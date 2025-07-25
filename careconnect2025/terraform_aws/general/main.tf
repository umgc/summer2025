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

data "aws_caller_identity" "current" {}

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
locals {
  params_keys = toset([for k, v in var.cc_ssm_params : k])
}
module "ssm" {
  source                = "./modules/ssm"
  default_tags          = var.default_tags
  params_keys           = local.params_keys
  cc_sensitive_params   = var.cc_ssm_params
}

module "iam" {
  source                               = "./modules/iam"
  default_tags                         = var.default_tags
  primary_region                       = var.primary_region
  cc_internal_bucket_arn               = module.s3_internal.internal_s3_bucket.arn
  only_compute_required_ssm_parameters = [for p in module.ssm.sensitive_params : p.arn]
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
  rds_username      = var.cc_ssm_params["DB_USER"]
  rds_password      = var.cc_ssm_params["DB_PASSWORD"]
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
  cc_ecs_sg_id              = module.vpc.cc_compute_sg_id
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
  source          = "./modules/amplify"
  default_tags    = var.default_tags
  primary_region  = var.primary_region
  cc_app_role_arn = module.iam.cc_app_role_arn
}

module "ses" {
  source         = "./modules/ses"
  default_tags   = var.default_tags
  primary_region = var.primary_region
  domain_name    = var.domain_name
}


module "main_api" {
  source                 = "./modules/api"
  cc_core_service_cm_arn = module.cloudmap.cloudmap_core_service_arn
  cc_main_api_role_arn   = module.iam.cc_api_gw_role.arn
  cc_vpc_id              = module.vpc.vpc_id
  cc_main_api_sg_id      = module.vpc.cc_main_api_sg_id
  cc_main_sbn_ids        = module.vpc.cc_subnet_ids
  default_tags           = var.default_tags
}

