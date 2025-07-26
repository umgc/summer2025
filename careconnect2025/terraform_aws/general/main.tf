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
  cc_app_role_arn         = module.iam.cc_app_role_info.arn
}
locals {
  params_keys = toset([for k, v in var.cc_ssm_params : k])
}
module "ssm" {
  source              = "./modules/ssm"
  default_tags        = var.default_tags
  params_keys         = local.params_keys
  cc_sensitive_params = var.cc_ssm_params
}

module "iam" {
  source                               = "./modules/iam"
  default_tags                         = var.default_tags
  primary_region                       = var.primary_region
  cc_internal_bucket_arn               = module.s3_internal.internal_s3_bucket.arn
  only_compute_required_ssm_parameters = [for p in module.ssm.sensitive_params : p.arn]
}

module "amplify" {
  source          = "./modules/amplify"
  default_tags    = var.default_tags
  primary_region  = var.primary_region
  cc_app_role_arn = module.iam.cc_app_role_info.arn
}

# To be reviewed and updated - This module needs a domain name to be set up properly
module "ses" {
  count = 0
  source         = "./modules/ses"
  default_tags   = var.default_tags
  primary_region = var.primary_region
  domain_name    = var.domain_name
}

### This will be moved to the terraform compute app
module "main_api" {
  source                 = "./modules/api"
  cc_main_api_role_arn   = module.iam.cc_api_gw_role.arn
  cc_vpc_id              = module.vpc.vpc_id
  cc_main_api_sg_id      = module.vpc.cc_main_api_sg_id
  cc_main_sbn_ids        = module.vpc.cc_subnet_ids
  default_tags           = var.default_tags
}

##### This module will be used for CI/CD soon ######
module "evb" {
  count = 0
  source                                    = "./modules/eventbridge"
  default_tags                              = var.default_tags
  cc_app_role_arn                           = module.iam.cc_app_role_info.arn
}

##### This module will be used for CI/CD soon ######
module "sfn_sm" {
  count = 0
  source          = "./modules/stepfunction"
  cc_app_role_arn = module.iam.cc_app_role_info.arn
  default_tags    = var.default_tags
}