
resource "aws_db_instance" "cc_db" {
  allocated_storage      = 100
  max_allocated_storage  = 250
  storage_type           = "io2"
  iops                   = 3000
  storage_encrypted      = true
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" // free tier
  identifier             = "cc-db"
  db_name                = "careconnect"
  username               = var.rds_username
  password               = var.rds_password
  vpc_security_group_ids = [var.cc_rds_sg_id]
  db_subnet_group_name   = var.cc_sbn_group_name
  skip_final_snapshot    = true
  tags                   = var.default_tags
}

# Comment PostgreSQL DB Instance for now as it is not being used yet for media uploads.

# resource "aws_db_instance" "cc_db_media" {
#  allocated_storage      = 100
#  max_allocated_storage  = 250
#  storage_type           = "io2"
#  iops                   = 3000
#  storage_encrypted      = true
#  engine                 = "postgres"
#  engine_version         = "17.4"
#  instance_class         = "db.m5.large"
#  identifier             = "cc-db"
#  username               = var.cc_rds_username
#  password               = var.cc_rds_password
#  vpc_security_group_ids = [var.cc_rds_sg_id]
#  db_subnet_group_name   = var.cc_sbn_group_name
# skip_final_snapshot    = true
#  tags                   = var.default_tags
#}
