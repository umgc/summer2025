
resource "aws_ssm_parameter" "cc_sensitive_env_variables" {
  for_each    = var.params_keys
  name        = each.key
  description = "Sensitive parameter for ${each.key}"
  type        = "SecureString"
  value       = var.cc_sensitive_params[each.key]
  tags        = var.default_tags
}