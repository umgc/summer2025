variable "iac_bucket_name" {
  description = "Name of the S3 bucket used for the back end for Terraform"
  default     = "cc-iac-us-east-1"
  validation {
    condition     = can(regex("^([a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1})$", var.iac_bucket_name))
    error_message = "Bucket name must follow S3 naming rules."
  }
}

variable "iac_table_name" {
  description = "Name of the DynamoDB Table use for the Backend for Terraform"
  default     = "cc-iac"
}