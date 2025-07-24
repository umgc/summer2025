
output "main_api_endpoint" {
  value = module.main_api.cc_man_api_endpoint
}
output "main_api_id" {
  value = module.main_api.cc_man_api_id
}
output "cc_api_gw_role" {
  value = module.iam.cc_api_gw_role
}
output "db_endpoint" {
  value = module.rds.cc_db_endpoint
}
output "db_port" {
  value = module.rds.cc_db_port
}
output "db_name" {
  value = module.rds.cc_db_name
}
output "cc_app_role_arn" {
  value = module.iam.cc_app_role_arn
}
output "cc_compute_sg_id" {
  value = module.vpc.cc_compute_sg_id
}
output "cc_sbn_ids" {
  value = module.vpc.cc_subnet_ids
}
output "amplify_url" {
  value = replace(module.amplify.amplify_branch_url, "/", ".")
}
output "cc_sensitive_env_variables_name" {
  value = {
    for key in local.params_keys : key => module.ssm.sensitive_params[key].name
  }
  sensitive = true
}

