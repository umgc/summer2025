variable "cc_ecr_repo_url" {
  type = string
}
variable "core_task_env_vars" {
  type    = list(map(string))
  default = []
}
variable "cloudmap_core_service_arn" {
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
variable "vpc_id" {
  type = string
}
variable "default_tags" {
  type = map(any)
}
variable "cc_ecs_exe_role_arn" {
  type        = string
  description = "The ECS execution role ARN used by the agent at startup to pull the image, create log group and run the task"
}
variable "cc_app_role_arn" {
  type        = string
  description = "The ECS task role ARN that the task/Spring Boot will use to access AWS services"
}