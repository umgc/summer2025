terraform {

  # Consider using workspaces for different environments backends like dev, staging, prod
  # That could help in naming the resources differently based on the environment
  backend "s3" {
    bucket       = "cc-iac-us-east-1-641592448579"
    key          = "tf-state/careconnect-db.tfstate"
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

resource "aws_db_instance" "cc_db" {
  allocated_storage      = 100
  max_allocated_storage  = 250
  storage_type           = "io2"
  iops                   = 3000
  storage_encrypted      = true
  engine                 = "mysql"
  engine_version         = "8.0.41"
  instance_class         = "db.t3.micro" // free tier
  identifier             = "cc-db"
  db_name                = "careconnect"
  username               = var.rds_username
  password               = var.rds_password
  vpc_security_group_ids = [data.terraform_remote_state.cc_common_state.outputs.cc_rds_sg_id]
  db_subnet_group_name   = data.terraform_remote_state.cc_common_state.outputs.cc_main_sbn_group_name
  skip_final_snapshot    = true
  tags                   = var.default_tags
}

locals {
  db_params = { 
    JDBC_URI = "jdbc:mysql://${aws_db_instance.cc_db.endpoint}/${aws_db_instance.cc_db.db_name}"
    DB_USER     = "${var.rds_username}"
    DB_PASSWORD = "${var.rds_password}"
  }
}

module "ssm" {
  source      = "./modules/ssm"
  default_tags = var.default_tags
  db_params   = local.db_params
  cc_app_role_name = data.terraform_remote_state.cc_common_state.outputs.cc_app_role_info.name
}
