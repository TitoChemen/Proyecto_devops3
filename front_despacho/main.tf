# 1. VPC y Redes (Se mantienen igual)
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

# SG Frontend: Acceso público
resource "aws_security_group" "sg_frontend" {
  name        = "sg_frontend_picker"
  vpc_id      = aws_vpc.proyec_sem_2_vpc.id

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

# SG Backends: Permite tráfico desde el Frontend en puertos comunes de API
resource "aws_security_group" "sg_backends" {
  name        = "sg_backends_picker"
  description = "Seguridad para microservicios de Despachos y Ventas"
  vpc_id      = aws_vpc.proyec_sem_2_vpc.id

  # Puerto para Backend Ventas (ejemplo: 3000)
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_frontend.id]
  }

  # Puerto para Backend Despachos (ejemplo: 5000)
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

# Frontend
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_frontend.id]
  key_name               = "vockey"
  iam_instance_profile   = "LabInstanceProfile"

  user_data = fileexists("frontend-userdata.sh") ? file("frontend-userdata.sh") : null

  tags = { Name = "Frontend-Picker" }
}

# Backend Ventas
resource "aws_instance" "backend_ventas" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_backends.id]
  key_name               = "vockey"
  iam_instance_profile   = "LabInstanceProfile"

  tags = { Name = "Backend-Ventas" }
}

# Backend Despachos
resource "aws_instance" "backend_despachos" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_backends.id]
  key_name               = "vockey"
  iam_instance_profile   = "LabInstanceProfile"

  tags = { Name = "Backend-Despachos" }
}

# 4. Outputs para conectar los servicios
output "url_frontend" {
  value = "http://${aws_instance.frontend.public_ip}"
}

output "endpoint_ventas_interno" {
  value = "http://${aws_instance.backend_ventas.private_ip}:3000"
}

output "endpoint_despachos_interno" {
  value = "http://${aws_instance.backend_despachos.private_ip}:5000"
}