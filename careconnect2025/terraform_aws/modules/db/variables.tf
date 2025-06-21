variable "cc_rds_sg_id" {
  type = string
}
variable "cc_sbn_group_name" {
  type = string
}
variable "cc_rds_kms_key_arn" {
  type = string
}
variable "default_tags" {
  type = map(any)
}