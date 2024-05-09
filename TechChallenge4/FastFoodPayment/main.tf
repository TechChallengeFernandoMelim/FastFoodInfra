### DYNAMO TABLE

resource "aws_dynamodb_table" "FastFoodPayment" {
  name           = var.dynamo_table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "pk"
  range_key      = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }
}

### ECR

resource "aws_ecr_repository" "fast_food_payment" {
  name                 = var.fast_food_payment_name_ecr
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.fast_food_payment]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.fast_food_payment.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.fast_food_payment.repository_url} && docker push ${aws_ecr_repository.fast_food_payment.repository_url}:latest"
  }
}

### SQS PRODUCTION QUEUE

resource "aws_sqs_queue" "fast_food_payment_queue" {
  name                        = "FastFoodProductionQueue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds = 60
  sqs_managed_sse_enabled = false
}

### LAMBDA

resource "aws_lambda_function" "fast_food_payment_management" {
  depends_on = [null_resource.push_image, aws_ecr_repository.fast_food_payment]
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      AWS_TABLE_NAME_DYNAMO = var.dynamo_table_name
      AWS_SQS_LOG               = var.SqsLogQueueUrl
      AWS_SQS_GROUP_ID_LOG      = var.SqsLogQueueGroupId
      AWS_SQS_PRODUCTION = aws_sqs_queue.fast_food_payment_queue.url
      AWS_SQS_GROUP_ID_PRODUCTION = aws_sqs_queue.fast_food_payment_queue.name
      ACCESS_TOKEN_MERCADO_PAGO = var.access_token_mercado_pago
      BASE_URL_MERCADO_PAGO = var.base_url_mercado_pago
      USER_ID_MERCADO_PAGO = var.user_id_mercado_pago
      EXTERNAL_POS_ID_MERCADO_PAGO = var.external_pos_id_mercado_pago
    }
  }
  package_type  = "Image"
  memory_size   = "500"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "FastFoodPayment"
  image_uri     = "${aws_ecr_repository.fast_food_payment.repository_url}:latest"
  role          = var.lambda_role
}

output "SqsProductionQueueUrl" {
  value = aws_sqs_queue.fast_food_payment_queue.url
}

output "lambda_arn_payment" {
  value = aws_lambda_function.fast_food_payment_management.invoke_arn
}

output "lambda_name_payment" {
  value = aws_lambda_function.fast_food_payment_management.function_name
}