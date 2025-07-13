variable "primary_region" {
  description = "The primary AWS region"
  default     = "us-east-1"
}
variable "default_tags" {
  type = map(string)
  default = {
    Purpose    = "capstone at UMGC"
    CourseCode = "SWEN-670"
    Project    = "careconnect"
    Use        = "IaC"
  }
}

variable "iac_bucket_name" {
  description = "Name of the S3 bucket used for the back end for Terraform"
  default     = "cc-iac-us-east-1"
  validation {
    condition     = can(regex("^([a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1})$", var.iac_bucket_name))
    error_message = "Bucket name must follow S3 naming rules."
  }
}
