variable "aws_region" {
  default = "us-east-1"
}

variable "github_repo" {
  description = "GitHub repo HTTPS URL (e.g., https://github.com/umgc/summer2025)"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_branch" {
  description = "The branch name to connect to Amplify"
  default     = "care-connect-develop"
}