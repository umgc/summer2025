

resource "aws_cloudwatch_event_rule" "s3_frontend_drop_rule" {
  name        = "s3-frontend-drop-rule"
  description = "Capture events for frontend build file uploaded to S3"
  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail = {
      reason = ["PutObject", "CompleteMultipartUpload", "CopyObject"]
      bucket = {
        name = ["${var.cc_iac_bucket_name}"]
      }
      object = {
        key = [{
          "prefix" = "${var.cc_frontend_build_prefix}"
        }]
      }
    }
  })
  tags = merge(var.default_tags, { Name : "s3-frontend-drop-rule" })
}

resource "aws_cloudwatch_event_target" "frontend_drop_target" {
  rule     = aws_cloudwatch_event_rule.s3_frontend_drop_rule.name
  arn      = var.cc_stm_arn
  role_arn = var.cc_app_role_arn
  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
    }
    input_template = <<-EOF
    {
      "flow"            : "ui",
      "bucket"          : "<bucket>",
      "key"             : "<key>",
      "amplifyAppId"    : "${var.cc_aplify_app_id}",
      "branchName"      : "${var.cc_frontend_branch_name}"
    }
    EOF
  }
  retry_policy {
    maximum_event_age_in_seconds = 90
    maximum_retry_attempts       = 5
  }
}