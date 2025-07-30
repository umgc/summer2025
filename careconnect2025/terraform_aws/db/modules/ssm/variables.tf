variable "default_tags" {
  type = map(any)
}
variable "db_params" {
  description = "Map of sensitive database parameters to be stored in SSM"
  type        = map(string)
}
variable "cc_app_role_name" {
  description = "The name of the IAM role that will access the SSM parameters"
  type        = string  
}