output "cc_api_gw_role" {
  value = aws_iam_role.cc_api_gw_role
}

output "cc_app_role_info" {
  value = {
    name = aws_iam_role.cc_app_role.name
    arn  = aws_iam_role.cc_app_role.arn
  }
}