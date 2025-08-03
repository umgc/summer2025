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
}
variable "cc_frontend_build_prefix" {
  description = "The prefix for the frontend build files in S3"
  type        = string
  default     = "cc-frontend-builds/"
}
variable "backend_bucket_check" { # That variable is just to ensure that the user has updated the backend S3 bucket name in main.tf
  description = "Did you update the backend S3 bucket name in the main.tf to your own?\nIt is used to store the Terraform state file."
  type        = bool  
}
