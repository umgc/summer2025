
terraform {
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

resource "aws_s3_bucket" "backend_bucket" {
  bucket        = "${var.iac_bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = merge(var.default_tags, { Name = "cc-iac-bucket" })
}

resource "aws_s3_bucket_versioning" "backend_bucket_versioning" {
  bucket = aws_s3_bucket.backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_state_crypto_conf" {
  bucket = aws_s3_bucket.backend_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}