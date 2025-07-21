terraform {

  # Consider using workspaces for different environments backends like dev, staging, prod
  # That could help in naming the resources differently based on the environment
  backend "s3" {
    bucket       = "cc-iac-us-east-1-641592448579"
    key          = "tf-state/careconnect.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
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

module "vpc" {
  source         = "./modules/vpc"
  default_tags   = var.default_tags
  primary_region = var.primary_region
}

module "s3_internal" {
  source                  = "./modules/s3"
  default_tags            = var.default_tags
  cc_internal_bucket_name = "cc-internal-file-storage-${var.primary_region}"
  cc_vpc_id               = module.vpc.vpc_id
  cc_app_role_arn         = module.iam.cc_app_role_arn
}

module "ssm" {
  source              = "./modules/ssm"
  default_tags        = var.default_tags
  rds_username        = var.rds_username
  rds_password        = var.rds_password
  rds_user_param_name = var.rds_user_param_name
  rds_pass_param_name = var.rds_pass_param_name
}
module "iam" {
  source                  = "./modules/iam"
  default_tags            = var.default_tags
  primary_region          = var.primary_region
  cc_internal_bucket_arn  = module.s3_internal.internal_s3_bucket.arn
  main_rds_user_param_arn = module.ssm.rds_username_param.arn
  main_rds_pass_param_arn = module.ssm.rds_password_param.arn
}

module "cloudmap" {
  source       = "./modules/cloudmap"
  default_tags = var.default_tags
  vpc_id       = module.vpc.vpc_id
}


module "rds" {
  source            = "./modules/db"
  cc_rds_sg_id      = module.vpc.cc_rds_sg
  cc_sbn_group_name = module.vpc.cc_db_main_sbn_group
  rds_username      = var.rds_username
  rds_password      = var.rds_password
  default_tags      = var.default_tags
}

module "ecr" {
  source       = "./modules/ecr"
  default_tags = var.default_tags
}

module "ecs" {
  source                    = "./modules/ecs"
  cc_ecr_repo_url           = module.ecr.core_repository_url
  subnet_ids                = module.vpc.cc_subnet_ids
  cc_ecs_sg_id              = module.vpc.cc_ecs_sg_id
  vpc_id                    = module.vpc.vpc_id
  cc_ecs_exe_role_arn       = module.iam.cc_ecs_exe_role_arn
  cc_app_role_arn           = module.iam.cc_app_role_arn
  core_task_env_vars        = var.core_task_env_vars
  cloudmap_core_service_arn = module.cloudmap.cloudmap_core_service_arn
  default_tags              = var.default_tags
}

module "evb" {
  source                                    = "./modules/eventbridge"
  default_tags                              = var.default_tags
  cc_core_cluster_name                      = module.ecs.cc_cluster.name
  cc_core_service_name                      = module.ecs.cc_core_service.name
  core_erc_repo_name                        = module.ecr.core_repository_name
  cc_core_task_definition_name              = module.ecs.cc_core_task_def_name
  cc_trigger_ecs_task_sfn_state_machine_arn = module.sfn_sm.sfn_state_machine_arn
  cc_app_role_arn                           = module.iam.cc_app_role_arn
}

module "sfn_sm" {
  source          = "./modules/stepfunction"
  cc_app_role_arn = module.iam.cc_app_role_arn
  default_tags    = var.default_tags
}

module "amplify" {
  source  = "./modules/amplify"
  default_tags    = var.default_tags
  primary_region = var.primary_region
  cc_app_role_arn = module.iam.cc_app_role_arn
}

module "ses" {
  source = "./modules/ses"
  default_tags    = var.default_tags
  primary_region = var.primary_region
  domain_name    = var.domain_name
}


# module "cognito" {
#   source       = "./modules/cognito"
#   default_tags = var.default_tags
# }

module "main_api" {
  source                 = "./modules/api"
  cc_core_service_cm_arn = module.cloudmap.cloudmap_core_service_arn
  cc_main_api_role_arn   = module.iam.cc_api_gw_role.arn
  cc_vpc_id              = module.vpc.vpc_id
  cc_main_api_sg_id      = module.vpc.cc_main_api_sg_id
  cc_main_sbn_ids        = module.vpc.cc_subnet_ids
  default_tags           = var.default_tags
  # cc_cognito_user_pool_arn = module.cognito.cc_cognito_user_pool
}

