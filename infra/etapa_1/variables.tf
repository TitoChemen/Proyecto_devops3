variable "region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "db_password" {
  description = "Contraseña de la base de datos RDS"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Usuario maestro de la base de datos"
  default     = "admin"
}

variable "project_name" {
  description = "Nombre del proyecto para prefijos de recursos"
  default     = "proyecto-semestral-2"
}