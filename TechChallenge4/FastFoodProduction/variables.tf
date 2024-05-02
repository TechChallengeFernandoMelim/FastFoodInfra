variable "dynamo_table_name" {
  default = "FastFoodProduction"
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

variable "fast_food_production_name_ecr" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr_fast_food_production"
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
variable "SqsProductionQueueUrl" {}