variable "primary_region" {
  description = "The primary AWS region"
  default     = "us-east-1"
}

variable "core_task_env_vars" {
  type    = list(map(string))
  default = []
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
variable "rds_user_param_name" {
  description = "RDS database username parameter name"
  type        = string
  default     = "cc-rds-username"
}
variable "rds_pass_param_name" {
  description = "RDS database password parameter name"
  type        = string
  default     = "cc-rds-password"
}
variable "rds_username" {
  description = "RDS database username"
  type        = string
  sensitive   = true
}
variable "rds_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}
variable "iac_cc_s3_bucket_name" {
  description = "S3 bucket name where application packages are stored"
  type        = string
}
variable "cc_main_backend_package_zip_s3key" {
  description = "Full S3 key for the main backend package zip file"
  type        = string
}
variable "cc_main_compute_env_vars" {
  type    = map(string)
  default = {}
}
variable "cors_allowed_list" {
  description = "List of allowed CORS origins"
  type        = string
  default     = "http://localhost:8080,http://localhost:*,http://127.0.0.1:*"
}
variable "cc_main_lambda_name" {
  description = "Name of the main backend Lambda function"
  type        = string
  default     = "cc_main_lambda_name"
}