
output "main_api_endpoint" {
  value = module.main_api.cc_man_api_endpoint
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
output "rds_pass_param_arn" {
  value = module.ssm.rds_password_param.arn
}
output "rds_user_param_arn" {
  value = module.ssm.rds_username_param.arn
}
