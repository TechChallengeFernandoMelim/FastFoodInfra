terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "AccessUser" {
  source = "./AccessUser"
}

module "FastFoodLogs" {
  source = "./FastFoodLogs"

  access_key_id     = module.AccessUser.access_key_id
  secret_access_key = module.AccessUser.secret_access_key
  lambda_role       = module.AccessUser.lambda_role
}