resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = var.default_tags
}

resource "aws_subnet" "private_subneta" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = "${var.primary_region}a"
}

resource "aws_subnet" "private_subnetb" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2)
  availability_zone = "${var.primary_region}b"
}

resource "aws_security_group" "cc_api_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.default_tags
}

resource "aws_security_group" "cc_ecs_lb_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "cc_ecs_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.cc_ecs_lb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cc_rds_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.cc_ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "cc_db_main_sbn_group" {
  name       = "cc-db-main-subnet-group"
  subnet_ids = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
}


# ----

# Security group for the VPC endpoints
resource "aws_security_group" "https_endpoints_sg" {
  name        = "https-endpoints-sg"
  description = "Allow HTTPS for endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECR API endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
}

# ECR DKR endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
}

# Cloudwatch endpoint
resource "aws_vpc_endpoint" "ecr_cloudwatch_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
}

# Secret manager endpoint
resource "aws_vpc_endpoint" "ecr_secret_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
}

resource "aws_route_table" "cc_main_vpc_rte_table" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "cc_main_rt_association_sbnb" {
  route_table_id = aws_route_table.cc_main_vpc_rte_table.id
  subnet_id      = aws_subnet.private_subnetb.id
}
# resource "aws_route_table_association" "cc_main_rt_association_sbna" {
#   route_table_id = aws_route_table.cc_main_vpc_rte_table.id
#   subnet_id      = aws_subnet.private_subneta.id
# }

# S3 Gateway endpoint (for ECR image layers)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = [aws_route_table.cc_main_vpc_rte_table.id]
  vpc_endpoint_type = "Gateway"
}
