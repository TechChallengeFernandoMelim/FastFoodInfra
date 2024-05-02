terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "postech_soat"

    workspaces {
      name = "aws-infrastructure-live"
    }
  }
}

provider "aws" {
  region = var.region
}

module "cluster_rds" {
  source = "./cluster_rds"
}

module "ecr" {
  source = "./ecr"
}

module "dynamo" {
  source = "./dynamo"
}

module "cloudwath" {
  source = "./cloudwatch"
}

module "cognito" {
  source = "./cognito"
}

module "authentication_lambda_access_key" {
  count  = var.create_lambda ? 1 : 0
  source = "./authentication_lambda_access_key"
}


module "lambda" {
  count  = var.create_lambda ? 1 : 0
  source = "./lambda"

  access_key_id               = module.authentication_lambda_access_key[0].access_key_id
  secret_access_key           = module.authentication_lambda_access_key[0].secret_access_key
  dynamodb_table_name         = module.dynamo.dynamodb_table_name
  cognito_user_pool_id        = module.cognito.cognito_user_pool_id
  cognito_user_pool_client_id = module.cognito.cognito_user_pool_client_id
  lambda_role                 = module.authentication_lambda_access_key[0].lambda_role
  ecr_user_repository_url     = module.ecr.ecr_user_repository_url
}

module "api_gateway" {
  count  = var.create_lambda ? 1 : 0
  source = "./api_gateway"

  cognito_user_pool_id        = module.cognito.cognito_user_pool_id
  cognito_user_pool_client_id = module.cognito.cognito_user_pool_client_id
  lambda_arn                  = module.lambda[0].lambda_arn
  lambda_name                 = module.lambda[0].lambda_name
  private_subnets_ids         = module.cluster_rds.private_subnets_ids
  security_group_id           = module.cluster_rds.security_group_id
  integration_uri_lb          = var.integration_uri_lb
}
