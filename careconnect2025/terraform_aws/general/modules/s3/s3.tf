data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cc_internal_bucket" {
  bucket        = "${var.cc_internal_bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = merge(var.default_tags, { Name = "${var.cc_internal_bucket_name}-${data.aws_caller_identity.current.account_id}" })
}

resource "aws_s3_bucket_versioning" "cc_internal_bucket_versioning" {
  bucket = aws_s3_bucket.cc_internal_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cc_internal_bucket_crypto_conf" {
  bucket = aws_s3_bucket.cc_internal_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_policy" "cc_default_policy" {
  bucket = aws_s3_bucket.cc_internal_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnEncryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cc_internal_bucket.arn}/*"
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      },
      {
        Sid    = "AllowCCInternalCompute"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "${var.cc_app_role_arn}"
          ]
        }
        Action   = "s3:*"
        Resource = ["${aws_s3_bucket.cc_internal_bucket.arn}", "${aws_s3_bucket.cc_internal_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "cc_internal_bucket_ownership" {
  bucket = aws_s3_bucket.cc_internal_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}