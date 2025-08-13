resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = merge(var.default_tags, { Name : "careconnect-vpc" })
}

### Create private and public subnets ##
########### START OF SUBNETS ###########
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

resource "aws_subnet" "public_subneta" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 3)
  tags       = merge(var.default_tags, { Name : "cc-public-subnet-a" })
}
########### END OF SUBNETS ###########

## Create Internet Gateway and NAT Gateway ##
resource "aws_internet_gateway" "cc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.default_tags, { Name : "cc-igw" })
}

resource "aws_eip" "cc_nat_public_eip" {
  tags = merge(var.default_tags, { Name : "cc-nat-eip" })
}

resource "aws_nat_gateway" "cc_to_public_natgw" {
  allocation_id = aws_eip.cc_nat_public_eip.id
  subnet_id     = aws_subnet.public_subneta.id

  tags = merge(var.default_tags, { Name : "cc-nat-gw" })
}
####### End of Internet Gateway and NAT Gateway ########


###### Create Route Tables and Associations ######
resource "aws_route_table" "cc_public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cc_igw.id
  }

  tags = merge(var.default_tags, { Name : "cc-public-rt" })
}

resource "aws_route" "cc_private_to_nat_route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.cc_to_public_natgw.id
}

resource "aws_route_table_association" "cc_main_rt_association_sbnb" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  subnet_id      = aws_subnet.private_subnetb.id
}

resource "aws_route_table_association" "cc_main_rt_association_sbna" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  subnet_id      = aws_subnet.private_subneta.id
}

resource "aws_route_table_association" "cc_public_rt_association_sbna" {
  route_table_id = aws_route_table.cc_public_rt.id
  subnet_id      = aws_subnet.public_subneta.id
}
###### End of Route Tables and Associations ######


###### Security Groups ######
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

resource "aws_security_group" "cc_compute_sg" {
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
    security_groups = [aws_security_group.cc_compute_sg.id]
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