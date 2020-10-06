resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.environment_name}-db-subnet-group"
  subnet_ids = [
    var.db_subnet_a_id,
    var.db_subnet_b_id
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "digitallearn_db" {
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  identifier             = "digitallearn-rds-${var.environment_name}"

  engine                          = "postgres"
  engine_version                  = "11.9"
  instance_class                  = var.instance_type
  allocated_storage               = var.instance_storage
  backup_retention_period         = var.backup_retention_period_days
  deletion_protection             = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true

  name     = "digitallearn_${var.environment_name}"
  username = var.db_username
  password = var.db_password

  lifecycle {
    prevent_destroy = true
  }
}
