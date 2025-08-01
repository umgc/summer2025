variable "default_tags" {
  type = map(string)
}
variable "cc_app_role_arn" {
  type        = string
  description = "The ARN of the IAM role that the Step Function will assume"
}
variable "cc_app_role_name" {
  type        = string
  description = "The name of the IAM role to add a policy for deployment"
}
variable "cc_apigw_role_arn" {
  type        = string
  description = "The ARN of the API Gateway role used for integration"
}
variable "cc_iac_bucket_name" {
  type        = string
  description = "The name of the internal S3 bucket used for Care Connect"
}
variable "cc_main_backend_build_prefix" {
  type        = string
  description = "The prefix for the main backend build files in S3"
}
variable "cc_lamnda_function_name" {
  type        = string
  description = "The name of the main backend Lambda function"
}
variable "cc_main_backend_lambda_arn" {
  type        = string
  description = "The ARN of the main backend Lambda function"
}
variable "cc_main_api_id" {
  type        = string
  description = "The API Gateway ID for the main backend"
}
variable "cc_deployment_sfn_arn" {
  type        = string
  description = "The ARN of the Step Function state machine for deployment"
}
variable "cc_api_integration_id" {
  type        = string
  description = "The ID of the API Gateway integration for the main backend"
}