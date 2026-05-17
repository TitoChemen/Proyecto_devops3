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
# 2. RED POR DEFECTO DE AWS ACADEMY (Anti-bloqueos)
# =================================================================
resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main-rds-subnet-group"
  subnet_ids = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  tags = {
    Name = "Main RDS Subnet Group"
  }
}

# =================================================================
# 3. GRUPO DE SEGURIDAD (Totalmente abierto para el lab)
# =================================================================
resource "aws_security_group" "sg_app" {
  name        = "sg_app_semestral"
  description = "Permitir todo el trafico en el laboratorio"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Todo entrante"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_app"
  }
}

# =================================================================
# 4. REPOSITORIOS ECR (Imágenes Docker)
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
# 5. INSTANCIAS EC2
# =================================================================
resource "aws_instance" "backend_despachos" {
  ami                    = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
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
  subnet_id              = aws_default_subnet.default_az2.id
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  key_name               = "vockey"

  tags = {
    Name = "frontend_despachos"
  }
}

# =================================================================
# 6. BASE DE DATOS RDS
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
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  skip_final_snapshot    = true
}