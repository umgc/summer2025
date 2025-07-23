terraform {

  # Consider using workspaces for different environments backends like dev, staging, prod
  # That could help in naming the resources differently based on the environment
  backend "s3" {
    bucket       = "cc-iac-us-east-1-641592448579"
    key          = "tf-state/careconnect-compute.tfstate"
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

data "terraform_remote_state" "cc_common_state" {
  backend = "s3"
  config = {
    bucket = "${var.iac_cc_s3_bucket_name}"
    key    = "tf-state/careconnect.tfstate"
    region = "us-east-1"
  }
}

resource "aws_cloudwatch_log_group" "cc_main_lambda_log_group" {
  name              = "/aws/lambda/cc_main_backend"
  retention_in_days = 90

  tags = merge(var.default_tags, {
    Name = "cc_lambda_main_backend_log_group"
  })
}

resource "aws_lambda_function" "cc_main_backend_lambda" {
  function_name = "cc_main_backend"
  description   = "Main backend Lambda function(Compute) for CareConnect"
  handler       = "com.careconnect.CcLambdaHandler::handleRequest"
  runtime       = "java17"
  role          = data.terraform_remote_state.cc_common_state.outputs.cc_app_role_arn
  memory_size   = 2048
  timeout       = 120
#   filename      = "NONAMEYET"
  s3_bucket     = var.iac_cc_s3_bucket_name
  s3_key        = var.cc_main_backend_package_zip_s3key
  publish       = true
  vpc_config {
    security_group_ids = [data.terraform_remote_state.cc_common_state.outputs.cc_compute_sg_id]
    subnet_ids         = data.terraform_remote_state.cc_common_state.outputs.cc_sbn_ids
  }
  environment {
    variables = merge(
      var.cc_main_compute_env_vars,
      {
        CC_APP_ROLE           = "${data.terraform_remote_state.cc_common_state.outputs.cc_app_role_arn}"
        APP_FRONTEND_BASE_URL = "https://${data.terraform_remote_state.cc_common_state.outputs.amplify_url}"
        BASE_URL              = "${data.terraform_remote_state.cc_common_state.outputs.main_api_endpoint}"
        CORS_ALLOWED_LIST     = "${var.cors_allowed_list},https://${data.terraform_remote_state.cc_common_state.outputs.amplify_url}"
        CC_DB_USER_SSM_PARAM  = "${data.terraform_remote_state.cc_common_state.outputs.rds_user_param_name}"
        CC_DB_PASS_SSM_PARAM  = "${data.terraform_remote_state.cc_common_state.outputs.rds_pass_param_name}"
        JDBC_URI              = "jdbc:mysql://${data.terraform_remote_state.cc_common_state.outputs.db_endpoint}/${data.terraform_remote_state.cc_common_state.outputs.db_name}"
        DB_USER               = "${data.terraform_remote_state.cc_common_state.outputs.rds_user_param_name}"
        DB_PASSWORD           = "${data.terraform_remote_state.cc_common_state.outputs.rds_pass_param_name}"
      }
    )
  }
  logging_config {
    log_group  = aws_cloudwatch_log_group.cc_main_lambda_log_group.name
    log_format = "Text"
  }
  snap_start {
    apply_on = "PublishedVersions"
  }
  tags = merge(var.default_tags, { Name = "cc_main_backend" })
}