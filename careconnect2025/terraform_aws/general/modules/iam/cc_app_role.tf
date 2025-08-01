resource "aws_iam_role" "cc_app_role" {
  name = "CCAPPROLE"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = [
          "events.amazonaws.com",
          "states.amazonaws.com",
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com",
          "amplify.amazonaws.com"
        ]
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
        Resource = var.only_compute_required_ssm_parameters
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
          "${aws_iam_role.cc_api_gw_role.arn}"
        ]
      },
      {
        Sid      = "AllowSNSPublish",
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = "arn:aws:sns:*:${data.aws_caller_identity.caller.account_id}:main_admin_email"
      },
      {
        Sid      = "AllowAmplifyStartDeployment",
        Effect   = "Allow",
        Action   = "amplify:StartDeployment",
        Resource = "arn:aws:amplify:*:${data.aws_caller_identity.caller.account_id}:apps/${var.cc_applify_app_id}/branches/*"
      },
      {
        Sid    = "LambdaGeneralAccess"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "xray:GetTrace*",
          "xray:BatchGetTraces",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:ListRoles",
          "iam:GetRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cc_app_role_policy_attach" {
  role       = aws_iam_role.cc_app_role.name
  policy_arn = aws_iam_policy.cc_app_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "cc_app_role_api_gw_policy_attach" {
  role       = aws_iam_role.cc_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
