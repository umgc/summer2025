variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Purpose    = "capstone at UMGC"
    CourseCode = "SWEN-670"
    Project    = "careconnect"
    Use        = "IaC"
  }
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
  description = "Environment variables for the main Lambda function"
  type        = map(string)
}
variable "cors_allowed_list" {
  description = "List of allowed CORS origins"
  type        = string
  default     = "http://localhost:*,http://127.0.0.1:*"
}