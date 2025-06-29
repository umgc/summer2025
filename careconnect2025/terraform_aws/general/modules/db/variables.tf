variable "cc_rds_sg_id" {
  type = string
}
variable "cc_sbn_group_name" {
  type = string
}
variable "default_tags" {
  type = map(any)
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