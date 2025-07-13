resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = merge(var.default_tags, { Name : "careconnect-vpc" })
}

resource "aws_subnet" "private_subneta" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = "${var.primary_region}a"
  tags              = merge(var.default_tags, { Name : "cc-private-subnet-a" })
}

resource "aws_subnet" "private_subnetb" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2)
  availability_zone = "${var.primary_region}b"
  tags              = merge(var.default_tags, { Name : "cc-private-subnet-b" })
}

resource "aws_security_group" "cc_api_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "cc-apigw-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, { Name : "cc-apigw-sg" })
}

resource "aws_security_group" "cc_ecs_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "cc-ecs-sg"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.cc_api_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, { Name : "cc-ecs-sg" })
}

resource "aws_security_group" "cc_rds_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "cc-rds-sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.cc_ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, { Name : "cc-rds-sg" })
}

resource "aws_db_subnet_group" "cc_db_main_sbn_group" {
  name       = "cc-db-main-subnet-group"
  subnet_ids = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  tags       = merge(var.default_tags, { Name : "cc-db-main-sbn-group" })
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
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, { Name : "internal-https-endpoints-sg" })
}

# ECR API endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
  tags                = merge(var.default_tags, { Name : "ecr-api-endpoint" })
}

# ECR DKR endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
  tags                = merge(var.default_tags, { Name : "ecr-dkr-endpoint" })
}

# Cloudwatch endpoint
resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
  tags                = merge(var.default_tags, { Name : "cloudwatch-endpoint" })
}

resource "aws_vpc_endpoint" "servicediscovery" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.primary_region}.servicediscovery"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
  tags = merge(var.default_tags, {
    Name = "cc-servicediscovery-endpoint"
  })
}

# Secret manager endpoint
resource "aws_vpc_endpoint" "secret_manager_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subneta.id, aws_subnet.private_subnetb.id]
  security_group_ids  = [aws_security_group.https_endpoints_sg.id]
  private_dns_enabled = true
  tags                = merge(var.default_tags, { Name : "secret-manager-endpoint" })
}


resource "aws_route_table_association" "cc_main_rt_association_sbnb" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  subnet_id      = aws_subnet.private_subnetb.id
}

# S3 Gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = [aws_vpc.vpc.main_route_table_id]
  vpc_endpoint_type = "Gateway"
  tags              = merge(var.default_tags, { Name : "s3-gateway-endpoint" })
}
