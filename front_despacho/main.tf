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

resource "aws_vpc" "proyec_sem_2_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC-proyec_sem_2"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.proyec_sem_2_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet-f-1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.proyec_sem_2_vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Permitir trafico HTTP y SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # En produccion, aqui iria solo tu IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 en us-east-1
  instance_type = "t2.micro"              # Capa gratuita

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "proyecto-semestral-2"
  }
}

# 6. Buscar la última imagen de Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 7. ¡La Instancia EC2 del Frontend!
resource "aws_instance" "frontend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  
  # CAMBIO 1: Usar vpc_security_group_ids (es lo correcto para VPC)
  vpc_security_group_ids = [aws_security_group.sg_front.id]
  
  # CAMBIO 2: La llave obligatoria de AWS Academy
  key_name      = "vockey"

  # CAMBIO 3: El perfil de IAM para Session Manager
  iam_instance_profile = "LabInstanceProfile"

  user_data = file("frontend-userdata.sh")

  tags = {
    Name = "Frontend-Innovatech"
  }
}

# 8. Outputs (Para que te de los datos al terminar)
output "ip_publica_frontend" {
  value = aws_instance.frontend.public_ip
}
output "vpc_id_para_el_backend" {
  value = aws_vpc.proyec_sem_2_vpc.id
}
output "sg_frontend_id_para_el_backend" {
  value = aws_security_group.sg_front.id
}