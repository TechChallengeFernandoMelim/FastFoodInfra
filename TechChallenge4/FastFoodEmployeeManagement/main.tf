### DYNAMO TABLE

resource "aws_dynamodb_table" "FastFoodEmployeeManagement" {
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

### COGNITO

resource "aws_cognito_user_pool" "FastFoodEmployees" {
  name                = var.pool_name
  username_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
  }

  password_policy {
    minimum_length                   = var.password_minimun_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }
}

resource "aws_cognito_user_pool_client" "FastFoodTotemEmployees" {
  depends_on      = [aws_cognito_user_pool.FastFoodEmployees]
  name            = var.app_client_name
  user_pool_id    = aws_cognito_user_pool.FastFoodEmployees.id
  generate_secret = false

  supported_identity_providers = ["COGNITO"]
  allowed_oauth_flows          = []
  allowed_oauth_scopes         = []
  explicit_auth_flows          = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "minutes"

  }
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity
}

### ECR

resource "aws_ecr_repository" "fast_food_employees" {
  name                 = var.fast_food_employees_name_ecr
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.fast_food_employees]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.fast_food_employees.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.fast_food_employees.repository_url} && docker push ${aws_ecr_repository.fast_food_employees.repository_url}:latest"
  }
}

### LAMBDA

resource "aws_lambda_function" "fast_food_employees_management" {
  depends_on = [null_resource.push_image, aws_ecr_repository.fast_food_employees]
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      AWS_TABLE_NAME_DYNAMO = var.dynamo_table_name
      AWS_EMPLOYEE_POOL_ID  = aws_cognito_user_pool.FastFoodEmployees.id
      AWS_CLIENT_ID_COGNITO = aws_cognito_user_pool_client.FastFoodTotemEmployees.id
      AWS_SQS               = var.SqsLogQueueUrl
      AWS_SQS_GROUP_ID      = var.SqsLogQueueGroupId
    }
  }
  package_type  = "Image"
  memory_size   = "500"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "FastFoodEmployeeManagement"
  image_uri     = "${aws_ecr_repository.fast_food_employees.repository_url}:latest"
  role          = var.lambda_role
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.FastFoodEmployees.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.FastFoodTotemEmployees.id
}

output "lambda_arn_employee" {
  value = aws_lambda_function.fast_food_employees_management.invoke_arn
}

output "lambda_name_employee" {
  value = aws_lambda_function.fast_food_employees_management.function_name
}