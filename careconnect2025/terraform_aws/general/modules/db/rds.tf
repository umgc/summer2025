
resource "aws_db_instance" "cc_db" {
  allocated_storage      = 100
  max_allocated_storage  = 250
  storage_type           = "io2"
  iops                   = 3000
  kms_key_id             = var.cc_rds_kms_key_arn
  storage_encrypted      = true
  engine                 = "postgres"
  engine_version         = "17.4"
  instance_class         = "db.m5.large"
  identifier             = "cc-db"
  username               = "test"
  password               = "password"
  vpc_security_group_ids = [var.cc_rds_sg_id]
  db_subnet_group_name   = var.cc_sbn_group_name
  skip_final_snapshot    = true
  tags                   = var.default_tags
}
