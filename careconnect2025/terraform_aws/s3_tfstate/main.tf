
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
  bucket = "${var.iac_bucket_name}-${data.aws_caller_identity.current.account_id}"
  tags   = merge(var.default_tags, { Name = "cc-iac-bucket" })
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

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.backend_bucket.bucket
  eventbridge = true
}

resource "aws_s3_bucket_policy" "s3_state_access" {
  bucket = aws_s3_bucket.backend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.backend_bucket.arn}/*",
        Condition = {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid    = "AllowAmplifyAccess"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.backend_bucket.arn}/cc-frontend-builds/*",
          "${aws_s3_bucket.backend_bucket.arn}/cc-backend-builds/*",
          "${aws_s3_bucket.backend_bucket.arn}/cc-backend-jars/*"
        ]
      },
      {
        Sid    = "AllowAmplifyListBucket"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "${aws_s3_bucket.backend_bucket.arn}"
      },
      {
        Sid    = "CiCdAccess",
        Effect = "Allow",
        Principal = {
          AWS = [
            # This enables the CI/CD pipeline (from the Step Functions) to access the S3 bucket.         
            # Uncomment the line below after creating the IAM role with the General Application. Then run a terraform apply.
            # "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CCAPPROLE",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        Action = "s3:*",
        Resource = [
          "${aws_s3_bucket.backend_bucket.arn}",
          "${aws_s3_bucket.backend_bucket.arn}/*"
        ]
      }
    ]
  })
}