variable "region" {
  default = "us-east-1"
  type    = string
}

variable "log_group_name" {
  default = "/FastFoodUserManagement/Logging"
  type    = string
}

variable "guest_user_name" {
  default = "guest@guest.com"
  type    = string
}

variable "guest_user_password" {
  default = "11111111111"
  type    = string
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}

variable "access_key_id" {}
variable "secret_access_key" {}
variable "dynamodb_table_name" {}
variable "cognito_user_pool_id" {}
variable "cognito_user_pool_client_id" {}
variable "lambda_role" {}
variable "ecr_user_repository_url" {}
