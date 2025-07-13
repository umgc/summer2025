output "internal_s3_bucket" {
  description = "The internal S3 bucket"
  value       = aws_s3_bucket.cc_internal_bucket

}