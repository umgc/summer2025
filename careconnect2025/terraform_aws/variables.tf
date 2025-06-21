variable "primary_region" {
  description = "The primary AWS region"
}

variable "alb_vs_lambda" {
  type = number
  description = "Do you want to enable an AWS Load Balancer (ALB) or our custom request proxy lambda? \nType\n1- ALB\n2-Custom Proxy Lambda"
}

variable "secondary_region" {
  description = "The secondary AWS region"
  default     = "us-west-2"
}

variable "default_tags" {
  type = map(any)
  default = {
    Purpose = "capstone"
    Project = "careconnect"
    Use     = "IaC State"
  }
}
