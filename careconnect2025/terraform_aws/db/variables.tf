variable "default_tags" {
  type = map(any)
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
variable "backend_bucket_check" { # That variable is just to ensure that the user has updated the backend S3 bucket name in main.tf
  description = "Did you update the backend S3 bucket name in the main.tf to your own?\nIt is used to store the Terraform state file."
  type        = bool  
}