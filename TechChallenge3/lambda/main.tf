resource "aws_lambda_function" "fast_food_user_management" {
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      AWS_TABLE_NAME_DYNAMO = var.dynamodb_table_name
      LOG_REGION            = var.region
      LOG_GROUP             = var.log_group_name
      AWS_USER_POOL_ID      = var.cognito_user_pool_id
      AWS_CLIENT_ID_COGNITO = var.cognito_user_pool_client_id
      GUEST_EMAIL           = var.guest_user_name
      GUEST_IDENTIFICATION  = var.guest_user_password
    }
  }
  package_type  = "Image"
  memory_size   = "128"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "FastFoodUserManagement"
  image_uri     = "${var.ecr_user_repository_url}:latest"
  role          = var.lambda_role
}

output "lambda_arn" {
  value = aws_lambda_function.fast_food_user_management.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.fast_food_user_management.function_name
}
