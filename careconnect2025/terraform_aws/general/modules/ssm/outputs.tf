output "sensitive_params" {
  value = {
    for key in var.params_keys : key => aws_ssm_parameter.cc_sensitive_env_variables[key]
  }
  sensitive = true
}