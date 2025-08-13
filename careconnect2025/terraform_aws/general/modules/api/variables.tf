variable "cc_main_api_role_arn" {
  type = string
}
variable "cc_vpc_id" {
  type = string
}
variable "cc_main_api_sg_id" {
  type = string
}
variable "cc_main_sbn_ids" {
  type = set(string)
}
# variable "cc_cognito_user_pool_arn" {
#   type = string
# }
variable "default_tags" {
  type = map(any)
}