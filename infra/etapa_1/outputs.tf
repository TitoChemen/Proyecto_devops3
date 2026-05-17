output "vpc_id" {
  value = aws_default_vpc.default.id
}

output "subnet_1a_id" {
  value = aws_default_subnet.default_az1.id
}

output "subnet_1b_id" {
  value = aws_default_subnet.default_az2.id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}

output "ip_publica_despachos" {
  value = aws_instance.backend_despachos.public_ip
}

output "ip_publica_frontend" {
  value = aws_instance.frontend.public_ip
}