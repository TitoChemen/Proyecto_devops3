# =================================================================
# 1. CONFIGURACIÓN DE PROVEEDORES
# =================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# =================================================================
# 2. RED (VPC, Subnets, Gateway y Tablas de Ruteo)
# =================================================================
resource "aws_vpc" "proyec_sem_2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "proyec-sem-2-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.proyec_sem_2_vpc.id

  tags = {
    Name = "proyec-sem-2-igw"
  }
}

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.proyec_sem_2_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.proyec_sem_2_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.proyec_sem_2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

# Subnet Group para la Base de Datos RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main-rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]

  tags = {
    Name = "Main RDS Subnet Group"
  }
}

# =================================================================
# 3. GRUPOS DE SEGURIDAD (Security Groups)
# =================================================================
resource "aws_security_group" "sg_app" {
  name        = "sg_app_semestral"
  description = "Permitir SSH, HTTP y puertos de la App"
  vpc_id      = aws_vpc.proyec_sem_2_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Ventas"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Despachos"
    from_port   = 8080
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

  tags = {
    Name = "sg_app"
  }
}

resource "aws_security_group" "sg_rds" {
  name        = "sg_rds_semestral"
  description = "Permitir conexion a MySQL desde las EC2"
  vpc_id      = aws_vpc.proyec_sem_2_vpc.id

  ingress {
    description     = "MySQL desde la subnet"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_rds"
  }
}

# =================================================================
# 4. REGISTROS REPOSITORIOS ECR (Docker Images)
# =================================================================
resource "aws_ecr_repository" "repo_frontend" {
  name                 = "devops-u2-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "repo_ventas" {
  name                 = "devops-u2-backend-ventas"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "repo_despachos" {
  name                 = "devops-u2-backend-despachos"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# =================================================================
# 5. INSTANCIAS EC2 (Servidores virtuales)
# =================================================================
resource "aws_instance" "backend_despachos" {
  ami                    = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  key_name               = "vockey"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              
              sudo mkdir -p /usr/local/lib/docker/cli-plugins/
              sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              EOF

  tags = {
    Name = "backend_despachos"
  }
}

resource "aws_instance" "frontend" {
  ami                    = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  key_name               = "vockey"

  tags = {
    Name = "frontend_despachos"
  }
}

# =================================================================
# 6. BASE DE DATOS RDS (MySQL)
# =================================================================
resource "aws_db_instance" "mysql_db" {
  allocated_storage      = 20
  db_name                = "bd_despacho"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "admin1234"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  skip_final_snapshot    = true
}