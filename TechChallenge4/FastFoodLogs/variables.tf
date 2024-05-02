variable "fast_food_logs_name" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr_fast_food_logs"
}


variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
  default     = "MUTABLE"
}

variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
  default     = "AES256"
}


variable "cloudwatch_group_name" {
  default = "/FastFoodLogs"
}

variable "region" {
  default = "us-east-1"
}

variable "log_group_name" {
  default = "/FastFoodLogs"
}


variable "access_key_id" {}
variable "secret_access_key" {}
variable "lambda_role" {}