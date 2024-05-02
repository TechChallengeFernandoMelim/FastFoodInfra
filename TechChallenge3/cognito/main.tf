resource "aws_cognito_user_pool" "FastFoodUsers" {
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

resource "aws_cognito_user_pool_client" "FastFoodTotem" {
  name            = var.app_client_name
  user_pool_id    = aws_cognito_user_pool.FastFoodUsers.id
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

resource "aws_cognito_user" "guest" {
  user_pool_id = aws_cognito_user_pool.FastFoodUsers.id
  username     = var.guest_user_name
  password     = var.guest_user_password

  attributes = {
    email          = var.guest_user_name
    email_verified = true
  }
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.FastFoodUsers.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.FastFoodTotem.id
}
