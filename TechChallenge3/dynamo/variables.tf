variable "dynamo_table_name" {
  default = "FastFoodUserManagement"
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
