output "cc_cluster" {
  value = aws_ecs_cluster.cc_main_cluster
}
output "cc_core_service" {
  value = aws_ecs_service.cc_core_service
}
output "cc_core_task_def_name" {
  value = aws_ecs_task_definition.cc_core_task_def.family
}