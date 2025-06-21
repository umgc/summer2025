terraform {

  backend "s3" {
    bucket         = "cc-iac-us-east-1"
    key            = "tf-state/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.0"
    }
  }
}

provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

module "iac_backend" {
  source          = "./modules/backend"
  iac_bucket_name = "cc-iac-${var.primary_region}"
  iac_table_name  = "cc-iac"
}

module "vpc" {
  source         = "./modules/vpc"
  default_tags   = var.default_tags
  primary_region = var.primary_region
}

module "iam" {
  source = "./modules/iam"
}

module "kms" {
  source = "./modules/kms"
}

module "rds" {
  source             = "./modules/db"
  cc_rds_sg_id       = module.vpc.cc_rds_sg
  cc_sbn_group_name  = module.vpc.cc_db_main_sbn_group
  cc_rds_kms_key_arn = module.kms.cc_rds_kms_key.arn
  default_tags       = var.default_tags
}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source          = "./modules/ecs"
  cc_ecr_repo_url = module.ecr.repository_url
  # rds_endpoint        = module.rds.cc_db_endpoint
  subnet_ids          = module.vpc.cc_subnet_ids
  cc_ecs_sg_id        = module.vpc.cc_ecs_sg_id
  cc_ecs_lb_sg_id     = module.vpc.cc_ecs_lb_sg_id
  vpc_id              = module.vpc.vpc_id
  cc_ecs_exe_role_arn = module.iam.cc_ecs_exe_role_arn
  default_tags        = var.default_tags
}


module "cognito" {
  source       = "./modules/cognito"
  default_tags = var.default_tags
}

module "main_api" {
  source                  = "./modules/api"
  cc_main_lb_listener_arn = module.ecs.cc_main_lb_listener_arn
  cc_main_api_role_arn    = module.iam.cc_api_gw_role.arn
  cc_vpc_id               = module.vpc.vpc_id
  cc_main_api_sg_id       = module.vpc.cc_main_api_sg_id
  cc_main_sbn_ids         = module.vpc.cc_subnet_ids
  default_tags            = var.default_tags
  # cc_cognito_user_pool_arn = module.cognito.cc_cognito_user_pool
}

# resource "aws_cognito_user_pool" "main" {
#   name = "main-user-pool"
# }

# resource "aws_cognito_user_pool_client" "main" {
#   user_pool_id = aws_cognito_user_pool.main.id
#   name         = "main-user-pool-client"
# }



# resource "aws_api_gateway_method" "main" {
#   rest_api_id   = aws_apigatewayv2_api.main.id
#   resource_id   = aws_api_gateway_resource.main.id
#   http_method   = "ANY"
#   authorization = "COGNITO_USER_POOLS"
#   authorizer_id = aws_api_gateway_authorizer.main.id
# }

# # resource "aws_api_gateway_deployment" "main" {
# #   rest_api_id = aws_api_gateway_rest_api.main.id
# #   stage_name  = "prod"
# # }

# resource "aws_api_gateway_authorizer" "main" {
#   name                   = "main-authorizer"
#   rest_api_id            = aws_apigatewayv2_api.main.id
#   identity_source        = "method.request.header.Authorization"
#   provider_arns          = [aws_cognito_user_pool.main.arn]
#   type                   = "COGNITO_USER_POOLS"
# }
