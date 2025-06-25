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

# resource "aws_iam_policy" "cc_api_to_alb_policy" {
#   name = "cc_api_to_alb_policy"
#   id = "cc_api_to_alb_policy"

#   description = "Policy for API Gateway to invoke ALB"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "elasticloadbalancing:Describe*",
#         "elasticloadbalancing:List*",
#         "elasticloadbalancing:Invoke"
#       ]
#       Resource = "*"
#     }]
#   })
#   tags = merge(var.default_tags, {Name: "cc_api_to_alb_policy"})
# }

# resource "aws_iam_role_policy_attachment" "attach_policies_to_api_role" {
#   role       = aws_iam_role.cc_api_gw_role.name
#   policy_arn = aws_iam_policy.cc_api_to_alb_policy.arn
# }
