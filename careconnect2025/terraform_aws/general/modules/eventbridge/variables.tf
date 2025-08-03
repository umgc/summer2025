variable "default_tags" {
  type = map(string)
}
variable "cc_app_role_arn" {
  type        = string
  description = "The ARN of the IAM role that the Step Function will assume"
}
variable "cc_stm_arn" {
  type        = string
  description = "The ARN of the Step Function state machine"
}
variable "cc_iac_bucket_name" {
  type        = string
  description = "The name of the internal S3 bucket used for Care Connect"
}
variable "cc_frontend_build_prefix" {
  type        = string
  description = "The prefix for the frontend build files in S3"
}
variable "cc_aplify_app_id" {
  type        = string
  description = "The Amplify App ID for the frontend application"
}
variable "cc_frontend_branch_name" {
  type        = string
  description = "The branch name for the frontend application in Amplify"
}