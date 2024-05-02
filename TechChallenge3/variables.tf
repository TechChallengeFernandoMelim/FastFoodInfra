variable "region" {
  type    = string
  default = "us-east-1"
}

variable "create_lambda" {
  type    = bool
  default = false
}

variable "integration_uri_lb" {
  type    = string
  default = "http://a3670aa530ba74770ac0a7eaefa7eb95-689856310.us-east-1.elb.amazonaws.com"
}