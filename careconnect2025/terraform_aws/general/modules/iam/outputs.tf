output "cc_api_gw_role" {
  value = aws_iam_role.cc_api_gw_role
}

output "cc_ecs_exe_role_arn" {
  value = aws_iam_role.ecs_exe_task_execution.arn
}

output "cc_app_role_arn" {
  value = aws_iam_role.cc_app_role.arn
}