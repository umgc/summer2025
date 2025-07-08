output "sfn_state_machine_arn" {
  value = aws_sfn_state_machine.trigger_ecs_tast_sfn_state_machine.arn
}