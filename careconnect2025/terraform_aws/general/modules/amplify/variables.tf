variable "default_tags" {
  type = map(any)
}
variable "primary_region" {
  type = string
}
variable "github_repo" {
  description = "GitHub repo HTTPS URL (e.g., https://github.com/umgc/summer2025)"
  type        = string
  default = "https://github.com/umgc/summer2025"
}
variable "github_branch" {
  description = "The branch name to connect to Amplify"
  default     = "care-connect-develop"
}
variable "cc_app_role_arn" {
  type        = string
  description = "The ECS task role ARN that the task/Spring Boot will use to access AWS services"
}