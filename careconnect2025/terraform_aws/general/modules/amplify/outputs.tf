output "amplify_app_id" {
  value = aws_amplify_app.amplify.id
}
output "amplify_branch_url" {
  value = "${aws_amplify_branch.care_connect_develop.branch_name}.${aws_amplify_app.amplify.default_domain}"
}
output "amplify_branch_name" {
  value = aws_amplify_branch.care_connect_develop.branch_name
}