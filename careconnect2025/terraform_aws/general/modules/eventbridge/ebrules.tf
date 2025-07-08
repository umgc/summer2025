resource "aws_cloudwatch_event_rule" "ecr_image_push_rule" {
  name        = "ecr-image-push-rule"
  description = "Event rule for ECR image push events"
  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type       = ["PUSH"]
      result            = ["SUCCESS"]
      "repository-name" = ["${var.core_erc_repo_name}"]
    }
  })
  tags = merge(var.default_tags, { Name : "core-ecr-image-push-rule" })
}
resource "aws_cloudwatch_event_target" "ecr_image_push_target" {
  rule     = aws_cloudwatch_event_rule.ecr_image_push_rule.name
  arn      = var.cc_trigger_ecs_task_sfn_state_machine_arn
  role_arn = var.cc_app_role_arn
  input = jsonencode({
    "taskDefinition" : var.cc_core_task_definition_name,
    "serviceName" : var.cc_core_service_name,
    "clusterName" : var.cc_core_cluster_name,
  })
  target_id = "ECRImagePushTarget"
  retry_policy {
    maximum_event_age_in_seconds = 90
    maximum_retry_attempts       = 5
  }
}