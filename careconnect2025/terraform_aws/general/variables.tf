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
