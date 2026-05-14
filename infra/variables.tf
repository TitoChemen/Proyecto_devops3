variable "key_name" {
  description = "Nombre de la llave en AWS para acceder a las instancias"
  default     = "vockey"
}
variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}