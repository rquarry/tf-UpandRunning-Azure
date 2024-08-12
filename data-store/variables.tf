variable "db_password" {
    description = "password for the database"
    type = string
    sensitive = true
}

variable "db_username" {
    description = "username for the database"
    type = string
    sensitive = true
}