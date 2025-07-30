resource "aws_cloudwatch_event_rule" "s3_backend_drop_rule" {
  name        = "s3-backend-drop-rule"
  description = "Capture events for backend build file uploaded to S3"
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail = {
      reason = ["PutObject"]
      bucket       = {
        name = ["${var.cc_iac_bucket_name}"]
      }
      object            = {
        key = [{
          "prefix" = "${var.cc_main_backend_build_prefix}"
        }]
      }
    }
  })
  tags = merge(var.default_tags, { Name : "s3-backend-drop-rule" })
}

resource "aws_cloudwatch_event_target" "backend_build_drop_target" {
  rule     = aws_cloudwatch_event_rule.s3_backend_drop_rule.name
  arn      = var.cc_deployment_sfn_arn
  role_arn = var.cc_app_role_arn
  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
    }
    input_template = <<-EOF
    {
      "flow"    : "lambda",
      "bucket"  : "<bucket>",
      "key"     : "<key>",
      "lambda"  : "${var.cc_lamnda_function_name}",
      "apigwid" : "${var.cc_main_api_id}"
    }
    EOF
  }
  retry_policy {
    maximum_event_age_in_seconds = 90
    maximum_retry_attempts       = 5
  }
}

resource "aws_cloudwatch_event_rule" "lambda_updated_rule" {
  name        = "lambda-version-published-rule"
  description = "Capture events for Lambda function state changes"
  event_pattern = jsonencode({
    source      = ["aws.lambda"]
    detail-type = ["Lambda Function State Change"]
    detail = {
      functionName = ["${var.cc_lamnda_function_name}"]  # Specify your function name
      state        = ["Active"]
      # Only trigger for versioned functions (not $LATEST)
      version = [{
        "anything-but": "$LATEST"
      }]
    }
  })
  tags = merge(var.default_tags, { Name : "lambda-version-published-rule" })
}

resource "aws_cloudwatch_event_target" "update_apigw_target" {
  rule     = aws_cloudwatch_event_rule.s3_backend_drop_rule.name
  arn      = var.cc_deployment_sfn_arn
  role_arn = var.cc_app_role_arn
  input_transformer {
    input_paths = {
      functionName = "$.detail.functionName"
      functionArn    = "$.detail.functionArn"
      version = "$.detail.version"
    }
    input_template = <<-EOF
    {
      "flow"          : "apigw",
      "functionArn"   : "<functionArn>",
      "functionName"  : "<functionName>",
      "version"       : "<version>",
      "integrationId" : "${var.api_integration_id}",
      "apigwid"       : "${var.cc_main_api_id}"
    }
    EOF
  }
  retry_policy {
    maximum_event_age_in_seconds = 90
    maximum_retry_attempts       = 5
  }
}
