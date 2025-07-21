variable "primary_region" {
  description = "The primary AWS region"
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "The secondary AWS region"
  default     = "us-west-2"
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
variable "domain_name" {
  description = "Your domain (e.g., example.com)"
  type        = string
}
