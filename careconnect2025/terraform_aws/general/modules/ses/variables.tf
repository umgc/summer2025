variable "domain_name" {
  type        = string
  description = "The domain name to use for SES and Route53"
  default     = "https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com/"
}
variable "default_tags" {
  type = map(any)
}
variable "primary_region" {
  type = string
}