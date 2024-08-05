variable "SqsLogQueueGroupId" {}
variable "SqsLogQueueUrl" {}
variable "access_key_id" {}
variable "secret_access_key" {}
variable "lambda_role" {}

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