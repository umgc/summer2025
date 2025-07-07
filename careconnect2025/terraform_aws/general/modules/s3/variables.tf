variable "default_tags" {
  type = map(any)
}
variable "cc_internal_bucket_name" {
  description = "Name of the internal S3 bucket for CareConnect"
  default     = "cc-internal-file-storage-us-east-1"
  validation {
    condition     = can(regex("^([a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1})$", var.cc_internal_bucket_name))
    error_message = "Bucket name must follow S3 naming rules."
  }

}
variable "cc_vpc_id" {
  type = string
}
variable "cc_app_role_arn" {
  type = string
}