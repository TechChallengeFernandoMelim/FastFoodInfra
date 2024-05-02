variable "ecr_totem_name" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr-fast_food_totem"
}

variable "ecr_user_name" {
  description = "The name of the ECR registry"
  type        = any
  default     = "ecr-fast_food_user_management"
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

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
