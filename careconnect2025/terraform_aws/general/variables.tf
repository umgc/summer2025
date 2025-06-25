variable "primary_region" {
  description = "The primary AWS region"
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "The secondary AWS region"
  default     = "us-west-2"
}

variable "billing_task_env_vars" {
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
