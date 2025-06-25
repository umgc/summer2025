resource "aws_iam_role" "ecs_task_execution" {
  name = "cc-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.default_tags, { Name : "cc-ecs-task-role" })
}


resource "aws_iam_role_policy_attachment" "ecs_execution_attach_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
