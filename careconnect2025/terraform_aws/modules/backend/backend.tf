resource "aws_s3_bucket" "backend_bucket" {
  bucket        = var.iac_bucket_name
  force_destroy = true
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

resource "aws_dynamodb_table" "backend_locks" {
  name         = var.iac_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Purpose = "capstone"
    Project = "careconnect"
    Type    = "DB"
    Use     = "IaC State"
  }
}