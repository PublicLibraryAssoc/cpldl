resource "aws_security_group" "db_security_group" {
  name        = "digitallearn-db-sg-${var.environment_name}"
  description = "Database security group within ${var.environment_name} VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      # Add ecs security groups
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
