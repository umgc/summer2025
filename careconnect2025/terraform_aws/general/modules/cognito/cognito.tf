resource "aws_cognito_user_pool" "cognito" {
  name = "cc-user-pool"
  tags = var.default_tags
}

resource "aws_cognito_user_pool_client" "cognito" {
  user_pool_id = aws_cognito_user_pool.cognito.id
  name         = "cc-user-pool-client"
}