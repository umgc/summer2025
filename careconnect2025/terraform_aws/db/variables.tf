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