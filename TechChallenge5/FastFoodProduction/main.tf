### DYNAMO TABLE

resource "aws_dynamodb_table" "FastFoodProduction" {
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

resource "aws_ecr_repository" "fast_food_production" {
  name                 = var.fast_food_production_name_ecr
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.fast_food_production]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.fast_food_production.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.fast_food_production.repository_url} && docker push ${aws_ecr_repository.fast_food_production.repository_url}:latest"
  }
}

### LAMBDA

resource "aws_lambda_function" "fast_food_production_management" {
  depends_on = [null_resource.push_image, aws_ecr_repository.fast_food_production]
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      AWS_TABLE_NAME_DYNAMO = var.dynamo_table_name
      AWS_SQS_LOG           = var.SqsLogQueueUrl
      AWS_SQS_GROUP_ID_LOG  = var.SqsLogQueueGroupId
      AWS_SQS_PRODUCTION    = var.SqsProductionQueueUrl
      PAYMENT_SERVICE_URL   = ""
    }
  }
  package_type  = "Image"
  memory_size   = "500"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "FastFoodProduction"
  image_uri     = "${aws_ecr_repository.fast_food_production.repository_url}:latest"
  role          = var.lambda_role
}

output "lambda_arn_production" {
  value = aws_lambda_function.fast_food_production_management.invoke_arn
}

output "lambda_name_production" {
  value = aws_lambda_function.fast_food_production_management.function_name
}