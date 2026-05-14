output "vpc_id" {
  value = aws_vpc.proyec_sem_2_vpc.id
}

output "subnet_1a_id" {
  value = aws_subnet.public_subnet_1a.id
}

output "subnet_1b_id" {
  value = aws_subnet.public_subnet_1b.id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}