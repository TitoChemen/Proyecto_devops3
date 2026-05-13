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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. VPC y Redes
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

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.proyec_sem_2_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "public-subnet-picker" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. Security Groups
resource "aws_security_group" "sg_frontend" {
  name   = "sg_frontend_picker"
  vpc_id = aws_vpc.proyec_sem_2_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "sg_backends" {
  name        = "sg_backends_picker"
  description = "Seguridad para microservicios de Despachos y Ventas"
  vpc_id      = aws_vpc.proyec_sem_2_vpc.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_frontend.id]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_frontend.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# 3. Instancias EC2
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_frontend.id]
  key_name               = "vockey"
  iam_instance_profile   = "LabInstanceProfile"
  user_data              = fileexists("frontend-userdata.sh") ? file("frontend-userdata.sh") : null
  tags                   = { Name = "Frontend-Picker" }
}

resource "aws_instance" "backend_ventas" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_backends.id]
  key_name               = "vockey"
  iam_instance_profile   = "LabInstanceProfile"
  tags                   = { Name = "Backend-Ventas" }
}

resource "aws_instance" "backend_despachos" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_backends.id]
  key_name               = "vockey"
  iam_instance_profile   = "LabInstanceProfile"
  tags                   = { Name = "Backend-Despachos" }
}