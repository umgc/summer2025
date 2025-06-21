output "cc_cognito_user_pool_endpoint" {
  value = aws_cognito_user_pool.cognito.endpoint
}
output "cc_user_pool_client" {
  value = aws_cognito_user_pool_client.cognito
}