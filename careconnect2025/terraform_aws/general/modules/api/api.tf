resource "aws_apigatewayv2_api" "cc_main_api" {
  name          = "cc-main-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = true
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["http://*", "https://*"]
    max_age           = 360
    expose_headers    = ["*"]
  }
  tags = var.default_tags
}

resource "aws_apigatewayv2_stage" "cc_main_api_stage" {
  api_id = aws_apigatewayv2_api.cc_main_api.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      contextPath             = "$context.path"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      dataProcessedBytes      = "$context.dataProcessed"
      integrationErrorMessage = "$context.integrationErrorMessage"
      errorMessage            = "$context.error.message"
      }
    )
  }
  tags = var.default_tags
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.cc_main_api.name}"
  retention_in_days = 60
  tags              = var.default_tags
}
