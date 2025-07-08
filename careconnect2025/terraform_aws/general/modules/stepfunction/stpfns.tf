
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
        "TaskDefinition.$": "$.taskDefinition"
      },
      "ResultPath": "$.taskDefinition",
      "Next": "RegisterNewTaskDefinition"
    },
    "RegisterNewTaskDefinition": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ecs:registerTaskDefinition",
      "Parameters": {
        "Family.$": "$.taskDefinition.TaskDefinition.Family",
        "TaskRoleArn.$": "$.taskDefinition.TaskDefinition.TaskRoleArn",
        "ExecutionRoleArn.$": "$.taskDefinition.TaskDefinition.ExecutionRoleArn",
        "NetworkMode.$": "$.taskDefinition.TaskDefinition.NetworkMode",
        "ContainerDefinitions.$": "$.taskDefinition.TaskDefinition.ContainerDefinitions",
        "Volumes.$": "$.taskDefinition.TaskDefinition.Volumes",
        "PlacementConstraints.$": "$.taskDefinition.TaskDefinition.PlacementConstraints",
        "RequiresCompatibilities.$": "$.taskDefinition.TaskDefinition.RequiresCompatibilities",
        "Cpu.$": "$.taskDefinition.TaskDefinition.Cpu",
        "Memory.$": "$.taskDefinition.TaskDefinition.Memory"
      },
      "ResultPath": "$.newTaskDefinition",
      "Next": "UpdateService"
    },
    "UpdateService": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ecs:updateService",
      "Parameters": {
        "Cluster.$": "$.clusterName",
        "Service.$": "$.serviceName",
        "TaskDefinition.$": "$.newTaskDefinition.TaskDefinition.TaskDefinitionArn"
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
