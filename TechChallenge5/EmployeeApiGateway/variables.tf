variable "api_name" {
  default = "FastFoodEmployeeApi"
  type    = string
}

variable "protocol_type" {
  default = "HTTP"
  type    = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "api_version" {
  default = "1"
}

variable "cognito_employee_pool_client_id" {}
variable "cognito_employee_pool_id" {}
variable "cognito_user_pool_id" {}
variable "cognito_user_pool_client_id" {}
variable "security_group_id" {}
variable "public_subnets_ids" {}
variable "lambda_arn_fast_food_totem" {}
variable "lambda_name_fast_food_totem" {}
variable "lambda_arn_fast_food_employee" {}
variable "lambda_name_fast_food_employee" {}
variable "lambda_arn_fast_food_payment" {}
variable "lambda_name_fast_food_payment" {}
variable "lambda_arn_fast_food_production" {}
variable "lambda_name_fast_food_production" {}