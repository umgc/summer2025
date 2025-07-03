
resource "aws_sfn_state_machine" "trigger_ecs_tast_sfn_state_machine" {
  name     = "cc-trigger-ecs-task-stm"
  role_arn = var.cc_app_role_arn

  definition = <<EOF
{
  "Comment": "Update ECS service when new ECR image is pushed",
  "StartAt": "GetTaskDefinition",
  "States": {
    "GetTaskDefinition": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ecs:describeTaskDefinition",
      "Parameters": {
        "TaskDefinition.$": "$.detail.resources[0].arn"
      },
      "ResultPath": "$.taskDefinition",
      "Next": "UpdateService"
    },
    
    "UpdateService": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ecs:updateService",
      "Parameters": {
        "Cluster": "your-cluster-name",
        "Service": "your-service-name",
        "TaskDefinition.$": "$.newTaskDefinition.taskDefinition.taskDefinitionArn"
      },
      "End": true
    }
  }
}
EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.log_group_for_sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
  tags = merge(var.default_tags, {
    "Name" = "cc-trigger-ecs-task-stm"
  })
}

resource "aws_cloudwatch_log_group" "log_group_for_sfn" {
  name = "/aws/sfn/states/cc-trigger-ecs-task-stm"
  lifecycle {
    prevent_destroy = false
  }
  retention_in_days = 60
  tags = merge(var.default_tags, {
    "Name" = "log-group-for-sfn-cc-trigger-ecs-task-stm"
  })
}

# "RegisterNewTaskDefinition": {
#       "Type": "Task",
#       "Resource": "arn:aws:states:::aws-sdk:ecs:registerTaskDefinition",
#       "Parameters": {
#         "Family.$": "$.taskDefinition.taskDefinition.family",
#         "TaskRoleArn.$": "$.taskDefinition.taskDefinition.taskRoleArn",
#         "ExecutionRoleArn.$": "$.taskDefinition.taskDefinition.executionRoleArn",
#         "NetworkMode.$": "$.taskDefinition.taskDefinition.networkMode",
#         "ContainerDefinitions.$": "States.Array(States.JsonMerge($.taskDefinition.taskDefinition.containerDefinitions[0], {\"image\": $.detail.repository-uri + \":\" + $.detail.image-tag}))",
#         "Volumes.$": "$.taskDefinition.taskDefinition.volumes",
#         "PlacementConstraints.$": "$.taskDefinition.taskDefinition.placementConstraints",
#         "RequiresCompatibilities.$": "$.taskDefinition.taskDefinition.requiresCompatibilities",
#         "Cpu.$": "$.taskDefinition.taskDefinition.cpu",
#         "Memory.$": "$.taskDefinition.taskDefinition.memory"
#       },
#       "ResultPath": "$.newTaskDefinition",
#       "Next": "UpdateService"
#     },