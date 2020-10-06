variable "environment_name" {}
variable "vpc_id" {}
variable "db_subnet_a_id" {}
variable "db_subnet_b_id" {}
variable "db_username" {}
variable "db_password" {}

variable "instance_type" { default = "db.t2.micro" }
variable "instance_storage" { default = 20 }
variable "backup_retention_period_days" { default = 7 }
