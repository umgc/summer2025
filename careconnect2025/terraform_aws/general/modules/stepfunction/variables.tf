variable "default_tags" {
  type = map(string)
}
variable "cc_app_role_arn" {
  type        = string
  description = "The ARN of the IAM role that the Step Function will assume to perform actions on AWS resources"
}