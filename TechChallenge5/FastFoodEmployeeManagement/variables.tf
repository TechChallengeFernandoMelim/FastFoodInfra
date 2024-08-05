variable "dynamo_table_name" {
  default = "FastFoodEmployeeManagement"
  type    = string
}

variable "billing_mode" {
  default = "PROVISIONED"
  type    = string
}

variable "read_capacity" {
  default = 1
  type    = string
}

variable "write_capacity" {
  default = 1
  type    = string
}

variable "pool_name" {
  default = "FastFoodEmployees"
  type    = string
}

variable "app_client_name" {
  default = "FastFoodTotemApi"
  type    = string
}

variable "access_token_validity" {
  default = 60
  type    = number
}

variable "id_token_validity" {
  default = 60
  type    = number
}

variable "refresh_token_validity" {
  default = 60
  type    = number
}

variable "password_minimun_length" {
  default = 11
  type    = number
}

variable "temporary_password_validity_days" {
  default = 7
  type    = number
}

variable "password_require_lowercase" {
  default = false
  type    = bool
}

variable "password_require_numbers" {
  default = false
  type    = bool
}

variable "password_require_symbols" {
  default = false
  type    = bool
}

variable "password_require_uppercase" {
  default = false
  type    = bool
}


variable "fast_food_employees_name_ecr" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr_fast_food_employees"
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

variable "access_key_id" {}
variable "secret_access_key" {}
variable "lambda_role" {}
variable "SqsLogQueueUrl" {}
variable "SqsLogQueueGroupId" {}
