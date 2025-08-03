
resource "aws_iam_policy" "cc_app_role_lambda_policy" {
  name        = "CcAppRoleDeploymentPolicy"
  description = "This policy allows API Gateway to invoke the main backend Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaActions",
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:ListVersion*",
          "lambda:PublishVersion",
        ]
        Resource = [
          "${var.cc_main_backend_lambda_arn}",
          "${var.cc_main_backend_lambda_arn}:*",
        ]
      },
      {
        Sid    = "AllowApiGwActions",
        Effect = "Allow"
        Action = [
          "apigateway:*",
        ]
        Resource = [
          "arn:aws:apigateway:*::/apis/${var.cc_main_api_id}/integrations/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cc_app_role_policy_attach" {
  role       = var.cc_app_role_name
  policy_arn = aws_iam_policy.cc_app_role_lambda_policy.arn
}