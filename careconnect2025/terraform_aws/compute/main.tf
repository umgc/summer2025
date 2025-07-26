terraform {

  # Consider using workspaces for different environments backends like dev, staging, prod
  # That could help in naming the resources differently based on the environment
  backend "s3" {
    bucket       = "cc-iac-us-east-1-641592448579"
    key          = "tf-state/careconnect-compute.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.0"
    }
  }
}

data "terraform_remote_state" "cc_common_state" {
  backend = "s3"
  config = {
    bucket = "${var.iac_cc_s3_bucket_name}"
    key    = "tf-state/careconnect.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cc_db_state" {
  backend = "s3"
  config = {
    bucket = "${var.iac_cc_s3_bucket_name}"
    key    = "tf-state/careconnect-db.tfstate"
    region = "us-east-1"
  }
}

resource "aws_cloudwatch_log_group" "cc_main_lambda_log_group" {
  name              = "/aws/lambda/cc_main_backend"
  retention_in_days = 90

  tags = merge(var.default_tags, {
    Name = "cc_lambda_main_backend_log_group"
  })
}

resource "aws_lambda_function" "cc_main_backend_lambda" {
  function_name = "cc_main_backend"
  description   = "Main backend Lambda function(Compute) for CareConnect"
  handler       = "com.careconnect.CcLambdaHandler::handleRequest"
  runtime       = "java17"
  role          = data.terraform_remote_state.cc_common_state.outputs.cc_app_role_info.arn
  memory_size   = 2048
  timeout       = 30
  s3_bucket     = var.iac_cc_s3_bucket_name
  s3_key        = var.cc_main_backend_package_zip_s3key
  publish       = true
  vpc_config {
    security_group_ids = [data.terraform_remote_state.cc_common_state.outputs.cc_compute_sg_id]
    subnet_ids         = data.terraform_remote_state.cc_common_state.outputs.cc_sbn_ids
  }
  environment {
    variables = merge(
      var.cc_main_compute_env_vars,
      data.terraform_remote_state.cc_common_state.outputs.cc_sensitive_env_variables_name,
      data.terraform_remote_state.cc_db_state.outputs.sensitive_params,
      {
        CC_APP_ROLE           = "${data.terraform_remote_state.cc_common_state.outputs.cc_app_role_arn}"
        APP_FRONTEND_BASE_URL = "https://${data.terraform_remote_state.cc_common_state.outputs.amplify_url}"
        BASE_URL              = "${data.terraform_remote_state.cc_common_state.outputs.main_api_endpoint}"
        CORS_ALLOWED_LIST     = "${var.cors_allowed_list},https://${data.terraform_remote_state.cc_common_state.outputs.amplify_url}"
      }
    )
  }
  logging_config {
    log_group  = aws_cloudwatch_log_group.cc_main_lambda_log_group.name
    log_format = "Text"
  }
  snap_start {
    apply_on = "PublishedVersions"
  }
  tags = merge(var.default_tags, { Name = "cc_main_backend" })
}

resource "aws_iam_policy" "cc_app_role_policy" {
  name        = "CcApiGatewayLambdaPolicy"
  description = "This policy allows API Gateway to invoke the main backend Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowInvokeLambda",
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "${aws_lambda_function.cc_main_backend_lambda.arn}",
          "${aws_lambda_function.cc_main_backend_lambda.arn}:*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cc_app_role_policy_attach" {
  role       = data.terraform_remote_state.cc_common_state.outputs.cc_api_gw_role.name
  policy_arn = aws_iam_policy.cc_app_role_policy.arn
}

resource "aws_apigatewayv2_integration" "main" {
  depends_on           = [aws_iam_role_policy_attachment.cc_app_role_policy_attach]
  api_id               = data.terraform_remote_state.cc_common_state.outputs.main_api_id
  integration_type     = "AWS_PROXY"
  integration_method   = "ANY"
  integration_uri      = aws_lambda_function.cc_main_backend_lambda.qualified_arn
  credentials_arn      = data.terraform_remote_state.cc_common_state.outputs.cc_api_gw_role.arn
  timeout_milliseconds = 30000
}

resource "aws_apigatewayv2_route" "cc_api_main_proxy" {
  api_id    = data.terraform_remote_state.cc_common_state.outputs.main_api_id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}