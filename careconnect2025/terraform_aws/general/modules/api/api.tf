resource "aws_apigatewayv2_api" "cc_main_api" {
  name          = "cc-main-api"
  protocol_type = "HTTP"
  tags          = var.default_tags
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
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
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

resource "aws_apigatewayv2_vpc_link" "cc_api_vpc_link" {
  name               = "cc-main-api-vpc-link"
  security_group_ids = [var.cc_main_api_sg_id]
  subnet_ids         = var.cc_main_sbn_ids

  tags = var.default_tags
}

# resource "aws_api_gateway_method" "api" {
#   rest_api_id   = aws_apigatewayv2_api.cc_main_api.id
#   resource_id   = aws_api_gateway_resource.api.id
#   http_method   = "ANY"
#   authorization = "COGNITO_USER_POOLS"
#   authorizer_id = aws_api_gateway_authorizer.cc_main_api_auth.id
# }

resource "aws_apigatewayv2_integration" "main" {
  api_id               = aws_apigatewayv2_api.cc_main_api.id
  integration_type     = "HTTP_PROXY"
  integration_method   = "ANY"
  connection_type      = "VPC_LINK"
  connection_id        = aws_apigatewayv2_vpc_link.cc_api_vpc_link.id
  integration_uri      = var.cc_core_service_cm_arn
  credentials_arn      = var.cc_main_api_role_arn
  timeout_milliseconds = 5000
}

resource "aws_apigatewayv2_route" "cc_api_main_proxy" {
  api_id    = aws_apigatewayv2_api.cc_main_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

# resource "aws_api_gateway_integration" "main" {
#   rest_api_id             = aws_apigatewayv2_api.cc_main_api.id
#   resource_id             = aws_api_gateway_resource.api.id
#   http_method             = aws_api_gateway_method.api.http_method
#   integration_http_method = "POST"
#   type                    = "HTTP_PROXY"
#   uri                     = var.cc_main_lb_dns
# }

# resource "aws_api_gateway_stage "main" {


# }

# resource "aws_api_gateway_deployment" "main" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   stage_name  = "prod"
# }

# resource "aws_api_gateway_authorizer" "cc_main_api_auth" {
#   name            = "main-authorizer"
#   rest_api_id     = aws_apigatewayv2_api.cc_main_api.id
#   identity_source = "method.request.header.Authorization"
#   provider_arns   = [var.cc_cognito_user_pool_arn]
#   type            = "COGNITO_USER_POOLS"
# }


# resource "aws_apigatewayv2_authorizer" "cognito" {
#   name             = "cognito-authorizer"
#   api_id           = aws_apigatewayv2_api.this.id
#   authorizer_type  = "JWT"
#   identity_sources = ["$request.header.Authorization"]
#   jwt_configuration {
#     audience = var.cognito_audience
#     issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
#   }
# }

# resource "aws_apigatewayv2_route" "secured" {
#   api_id             = aws_apigatewayv2_api.this.id
#   route_key          = var.route_key
#   target             = "integrations/${aws_apigatewayv2_integration.alb.id}"
#   authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
#   authorization_type = "JWT"
# }