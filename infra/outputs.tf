output "url_frontend" {
  value = "http://${aws_instance.frontend.public_ip}"
}

output "endpoint_ventas_interno" {
  value = "http://${aws_instance.backend_ventas.private_ip}:3000"
}

output "endpoint_despachos_interno" {
  value = "http://${aws_instance.backend_despachos.private_ip}:5000"
}
