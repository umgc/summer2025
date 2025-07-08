resource "aws_iam_role" "cc_api_gw_role" {
  name = "cc_api_gw_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.default_tags, { Name : "cc_api_gw_role" })
}
