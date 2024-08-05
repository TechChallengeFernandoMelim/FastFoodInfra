### ECR
resource "aws_ecr_repository" "fast_food_logs" {
  name                 = var.fast_food_logs_name
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

}

### CLOUDWATCH

resource "aws_cloudwatch_log_group" "fast_food_logs" {
  name = var.cloudwatch_group_name
}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.fast_food_logs]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.fast_food_logs.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.fast_food_logs.repository_url} && docker push ${aws_ecr_repository.fast_food_logs.repository_url}:latest"
  }
}

### LAMBDA

resource "aws_lambda_function" "fast_food_user_management" {
  depends_on = [null_resource.push_image, aws_cloudwatch_log_group.fast_food_logs]
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      LOG_REGION            = var.region
      LOG_GROUP             = var.log_group_name
    }
  }
  package_type  = "Image"
  memory_size   = "500"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "FastFoodLogs"
  image_uri     = "${aws_ecr_repository.fast_food_logs.repository_url}:latest"
  role          = var.lambda_role
}

### SQS QUEUE

resource "aws_sqs_queue" "fast_food_queue" {
  name                        = "FastFoodLogQueue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds = 60
  sqs_managed_sse_enabled = false
}

### LAMBDA TRIGGER

resource "aws_lambda_event_source_mapping" "fast_food__log_lambda_trigger" {
  depends_on        = [aws_sqs_queue.fast_food_queue, aws_lambda_function.fast_food_user_management]
  event_source_arn  = aws_sqs_queue.fast_food_queue.arn
  function_name     = aws_lambda_function.fast_food_user_management.arn
}


### OUTPUT

output "SqsLogQueueUrl"{
  value = aws_sqs_queue.fast_food_queue.url
}

output "SqsLogQueueGroupId"{
  value = aws_sqs_queue.fast_food_queue.name
}