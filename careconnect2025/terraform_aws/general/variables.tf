variable "primary_region" {
  description = "The primary AWS region"
  default     = "us-east-1"
}

variable "default_tags" {
  type = map(any)
  default = {
    Purpose    = "capstone at UMGC"
    CourseCode = "SWEN-670"
    Project    = "careconnect"
    Use        = "IaC"
  }
}
variable "domain_name" {
  description = "Your domain (e.g., example.com)"
  type        = string
}

variable "cc_ssm_params" {
  description = "List of secure SSM parameters to be created"
  type        = map(string)
}

variable "cc_iac_bucket_name" {
  description = "The name of the S3 bucket used for Care Connect infrastructure as code"
  type        = string
  default     = "cc-iac-us-east-1-641592448579"
}
variable "cc_frontend_build_prefix" {
  description = "The prefix for the frontend build files in S3"
  type        = string
  default     = "cc-frontend-builds"
}
