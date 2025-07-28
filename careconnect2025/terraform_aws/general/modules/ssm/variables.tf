variable "default_tags" {
  type = map(string)
}

variable "params_keys" {
  description = "Set of keys of parameters to be created in SSM"
  type        = set(string)
  default     = []
}
variable "cc_sensitive_params" {
  description = "List of secure SSM parameters to be created"
  type        = map(string)
  default     = {}
}
