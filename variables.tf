variable "ami" {
    type = string
    default = "ami-0b6c6ebed2801a5cb"
  
}

variable "instance_type" {
    type = string
    default = "t2.micro"
  
}

variable "key_name" {
    type = string
    default = "maryamkey"
}

variable "region" {
  default = "us-east-1"
}

variable "db_name" {
  default = "prestashopdb"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_user" {
  default = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
