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
variable "only_compute_required_ssm_parameters" {
  description = "List of SSM parameters required for the main Lambda function"
  type        = list(string)
}