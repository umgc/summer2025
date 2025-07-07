variable "default_tags" {
  type = map(string)
}
variable "rds_username" {
  description = "RDS database username"
  type        = string
  sensitive   = true
}
variable "rds_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}
variable "rds_user_param_name" {
  description = "RDS database username parameter name"
  type        = string
}
variable "rds_pass_param_name" {
  description = "RDS database password parameter name"
  type        = string
}