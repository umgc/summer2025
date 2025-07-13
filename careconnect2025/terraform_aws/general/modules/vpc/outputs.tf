output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "cc_rds_sg" {
  value = aws_security_group.cc_rds_sg.id
}
output "cc_db_main_sbn_group" {
  value = aws_db_subnet_group.cc_db_main_sbn_group.name
}
output "cc_subnet_ids" {
  value = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
}
output "cc_ecs_sg_id" {
  value = aws_security_group.cc_ecs_sg.id
}
# output "cc_ecs_lb_sg_id" {
#   value = aws_security_group.cc_ecs_lb_sg.id
# }
output "cc_main_api_sg_id" {
  value = aws_security_group.cc_api_sg.id
}
output "https_endpoints_sg" {
  value = aws_security_group.https_endpoints_sg
}