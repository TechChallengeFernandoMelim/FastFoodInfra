variable "pool_name" {
  default = "FastFoodUsersTest"
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


variable "guest_user_name" {
  default = "guest@guest.com"
  type    = string
}

variable "guest_user_password" {
  default = "11111111111"
  type    = string
}
