terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ==========================================
# 1. VPC Y REDES (Basado en tu código original)
# ==========================================
resource "aws_vpc" "proyec_sem_2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "VPC-proyec_sem_2" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.proyec_sem_2_vpc.id
  tags   = { Name = "main-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.proyec_sem_2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Subred 1 (La que ya tenías)
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.proyec_sem_2_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "public-subnet-1a" }
}

# Subred 2 (NUEVA: Obligatoria para RDS y Balanceador de Carga)
resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.proyec_sem_2_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags                    = { Name = "public-subnet-1b" }
}

resource "aws_route_table_association" "public_assoc_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# 2. SEGURIDAD Y BASE DE DATOS (RDS)
# ==========================================
resource "aws_security_group" "sg_rds" {
  name        = "sg_rds_picker"
  vpc_id      = aws_vpc.proyec_sem_2_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main-rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage      = 20
  db_name                = "db_ventas_despachos"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

# ==========================================
# 3. REPOSITORIOS DE IMÁGENES (ECR)
# ==========================================
resource "aws_ecr_repository" "repo_ventas" {
  name                 = "${var.project_name}-ventas"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "repo_despachos" {
  name                 = "${var.project_name}-despachos"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "repo_frontend" {
  name                 = "${var.project_name}-frontend"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}