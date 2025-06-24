variable "primary_region" {
  description = "The primary AWS region"
  default = "us-east-1"
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
