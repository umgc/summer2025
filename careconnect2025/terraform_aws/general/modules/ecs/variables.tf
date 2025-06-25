variable "cc_ecr_repo_url" {
  type = string
}
variable "billing_task_env_vars" {
  type    = list(map(string))
  default = []
}
variable "cloudmap_billing_service" {
  type = string
}
# variable "rds_endpoint" {
#   type = string
# }
variable "subnet_ids" {
  type = list(any)
}
variable "cc_ecs_sg_id" {
  type = string
}
variable "cc_ecs_lb_sg_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "default_tags" {
  type = map(any)
}
variable "cc_ecs_exe_role_arn" {
  type = string
}