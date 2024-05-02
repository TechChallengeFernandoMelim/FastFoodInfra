variable "dynamo_table_name" {
  default = "FastFoodPayment"
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

variable "fast_food_payment_name_ecr" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr_fast_food_payment"
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

variable "access_token_mercado_pago" {
  default = "TEST-374986483149722-041110-a1b4a27ab0bfc4e0cc5457230d9d5f96-68960270"
  type    = string
}

variable "base_url_mercado_pago" {
  default = "https://api.mercadopago.com"
  type    = string
}

variable "user_id_mercado_pago" {
  default = "68960270"
  type    = string
}

variable "external_pos_id_mercado_pago" {
  default = "12"
  type    = string
}

variable "access_key_id" {}
variable "secret_access_key" {}
variable "lambda_role" {}
variable "SqsLogQueueUrl" {}
variable "SqsLogQueueGroupId" {}