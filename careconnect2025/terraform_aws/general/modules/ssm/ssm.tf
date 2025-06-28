resource "aws_ssm_parameter" "rds_username_param" {
  name        = var.rds_user_param_name
  description = "RDS database username"
  type        = "SecureString"
  value       = var.rds_username
  overwrite   = true
  tags        = var.default_tags
}

resource "aws_ssm_parameter" "rds_password_param" {
  name        = var.rds_pass_param_name
  description = "RDS database password"
  type        = "SecureString"
  value       = var.rds_password
  overwrite   = true
  tags        = var.default_tags
}