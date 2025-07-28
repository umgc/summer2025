
# To be updated to deploy the amplify UI

# resource "aws_cloudwatch_log_group" "log_group_for_sfn" {
#   name = "/aws/sfn/states/cc-trigger-ecs-task-stm"
#   lifecycle {
#     prevent_destroy = false
#   }
#   retention_in_days = 60
#   tags = merge(var.default_tags, {
#     "Name" = "log-group-for-sfn-cc-trigger-ecs-task-stm"
#   })
# }
