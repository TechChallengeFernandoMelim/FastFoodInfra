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

module "FastFoodUserManagement" {
  source = "./FastFoodUserManagement"

  access_key_id      = module.AccessUser.access_key_id
  secret_access_key  = module.AccessUser.secret_access_key
  lambda_role        = module.AccessUser.lambda_role
  SqsLogQueueGroupId = module.FastFoodLogs.SqsLogQueueGroupId
  SqsLogQueueUrl     = module.FastFoodLogs.SqsLogQueueUrl
}

module "FastFoodEmployeeManagement" {
  source = "./FastFoodEmployeeManagement"

  access_key_id      = module.AccessUser.access_key_id
  secret_access_key  = module.AccessUser.secret_access_key
  lambda_role        = module.AccessUser.lambda_role
  SqsLogQueueGroupId = module.FastFoodLogs.SqsLogQueueGroupId
  SqsLogQueueUrl     = module.FastFoodLogs.SqsLogQueueUrl
}

module "FastFoodPayment" {
  source = "./FastFoodPayment"

  access_key_id      = module.AccessUser.access_key_id
  secret_access_key  = module.AccessUser.secret_access_key
  lambda_role        = module.AccessUser.lambda_role
  SqsLogQueueGroupId = module.FastFoodLogs.SqsLogQueueGroupId
  SqsLogQueueUrl     = module.FastFoodLogs.SqsLogQueueUrl
}

module "FastFoodProduction" {
  source = "./FastFoodProduction"

  access_key_id         = module.AccessUser.access_key_id
  secret_access_key     = module.AccessUser.secret_access_key
  lambda_role           = module.AccessUser.lambda_role
  SqsLogQueueGroupId    = module.FastFoodLogs.SqsLogQueueGroupId
  SqsLogQueueUrl        = module.FastFoodLogs.SqsLogQueueUrl
  SqsProductionQueueUrl = module.FastFoodPayment.SqsProductionQueueUrl
}

module "FastFoodTotem" {
  source = "./FastFoodTotem"

  SqsLogQueueUrl     = module.FastFoodLogs.SqsLogQueueUrl
  SqsLogQueueGroupId = module.FastFoodLogs.SqsLogQueueGroupId
  PaymentServiceUrl  = ""
  access_key_id      = module.AccessUser.access_key_id
  secret_access_key  = module.AccessUser.secret_access_key
  lambda_role        = module.AccessUser.lambda_role

}


module "UserApiGateway" {
  source = "./UserApiGateway"
}


module "EmployeeApiGateway" {
  source = "./EmployeeApiGateway"
}

