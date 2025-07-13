variable "default_tags" {
  type = map(any)
}
variable "primary_region" {
  type = string
}
variable "cc_internal_bucket_arn" {
  description = "ARN of the internal S3 bucket for CareConnect"
  type        = string
}
variable "main_rds_user_param_arn" {
  description = "ARN of the main RDS user parameter store"
  type        = string
}
variable "main_rds_pass_param_arn" {
  description = "ARN of the main RDS password parameter store"
  type        = string
}