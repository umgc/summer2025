resource "aws_iam_role" "ecs_exe_task_execution" {
  name = "cc-ecs-exe-role"

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
  tags = merge(var.default_tags, { Name : "cc-ecs-exe-role" })
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "cc-ecs-execution-policy"
  description = "Policy for ECS task execution"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach_policy" {
  role       = aws_iam_role.ecs_exe_task_execution.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

resource "aws_iam_role" "cc_app_role" {
  name = "CCAPPROLE"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = ["ecs-tasks.amazonaws.com",
          "events.amazonaws.com",
        "states.amazonaws.com"]
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.default_tags, { Name : "CCAPPROLE" })
}

data "aws_caller_identity" "caller" {}

resource "aws_iam_policy" "cc_app_role_policy" {
  name        = "CCAPPROLEPolicy"
  description = "This role is used by our compute for CareConnect to access S3, RDS and Secrets Manager..."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessS3",
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "${var.cc_internal_bucket_arn}",
          "${var.cc_internal_bucket_arn}/*"
        ]
      },
      {
        Sid    = "AccessRDS",
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ]
        Resource = "*"
      },
      {
        Sid    = "AccessSSMParameters",
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParam*",
          "ssm:PutParameter",
        ]
        Resource = ["${var.main_rds_user_param_arn}",
        "${var.main_rds_pass_param_arn}"]
      },
      {
        Sid    = "AccessCloudWatchLogs",
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "StepFunctionAccess",
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecr:DescribeImages"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEvtBridgeOnSfn"
        Effect = "Allow",
        Action = [
          "states:StartExecution"
        ],
        Resource = [
          "arn:aws:states:*:${data.aws_caller_identity.caller.account_id}:stateMachine:*"
        ]
      },
      {
        Sid    = "AllowSelfRolePass"
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "${aws_iam_role.cc_app_role.arn}",
          "${aws_iam_role.ecs_exe_task_execution.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cc_app_role_policy_attach" {
  role       = aws_iam_role.cc_app_role.name
  policy_arn = aws_iam_policy.cc_app_role_policy.arn
}
