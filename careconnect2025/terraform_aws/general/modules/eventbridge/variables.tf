variable "default_tags" {
  type = map(string)
}
variable "core_erc_repo_name" {
  type = string
}
variable "cc_core_service_name" {
  type        = string
  description = "The name of the ECS service that will be updated by the Step Function"
}
variable "cc_core_cluster_name" {
  type        = string
  description = "The name of the ECS cluster that contains the service to be updated"
}
variable "cc_trigger_ecs_task_sfn_state_machine_arn" {
  type        = string
  description = "The ARN of the Step Function state machine that triggers the ECS task"
}
variable "cc_app_role_arn" {
  type        = string
  description = "The ARN of the IAM role that the Step Function will assume to trigger the ECS task"
}
variable "cc_core_task_definition_name" {
  type = string
}