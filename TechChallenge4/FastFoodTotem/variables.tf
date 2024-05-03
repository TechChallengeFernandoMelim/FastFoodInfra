


variable "cluster_name" {
  default = "eks-fiap_4soat"
}

variable "fast_food_totem_name_ecr" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr_fast_food_totem"
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

variable "dbuser"{
    default = "sa"
}

variable "dbpassword" {
    default = "Fernando9+"
}

variable "PaymentServiceUrl" {}
variable "SqsLogQueueGroupId" {}
variable "SqsLogQueueUrl" {}
variable "access_key_id" {}
variable "secret_access_key" {}
variable "lambda_role" {}