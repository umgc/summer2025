output "cc_db_endpoint" {
  value = aws_db_instance.cc_db.endpoint
}
output "cc_db_port" {
  value = aws_db_instance.cc_db.port
}
output "cc_db_name" {
  value = aws_db_instance.cc_db.db_name
}
output "sensitive_params" {
  value = module.ssm.sensitive_params
  sensitive = true
}