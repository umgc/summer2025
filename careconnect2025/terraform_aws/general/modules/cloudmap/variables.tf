variable "vpc_id" {
  description = "The ID of the VPC for a private DNS namespace."
  type        = string
}

variable "default_tags" {
  description = "A map of the defaulttags to assign to the resources."
  type        = map(string)
}
