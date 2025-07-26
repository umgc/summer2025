
resource "aws_ssm_parameter" "cc_sensitive_env_variables" {
  for_each    = var.db_params
  name        = each.key
  description = "Sensitive parameter for ${each.key}"
  type        = "SecureString"
  overwrite = true
  value       = var.db_params[each.key]
  tags        = var.default_tags
}

resource "aws_iam_policy" "cc_app_role_policy" {
  name        = "CcAllowDbSsmAccess"
  description = "This policy allows CCAPPROLE to access the parameters for the database connection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessSSMParameters",
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParam*",
          "ssm:PutParameter",
        ]
        Resource = [ for p in aws_ssm_parameter.cc_sensitive_env_variables: p.arn ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cc_app_role_policy_attach" {
  role       = var.cc_app_role_name
  policy_arn = aws_iam_policy.cc_app_role_policy.arn
}

output "sensitive_params" {
  value = {
    for key in toset([for k, v in var.db_params : k]) : key => aws_ssm_parameter.cc_sensitive_env_variables[key].name
  }
  sensitive = true
}