resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.environment_name}-db-subnet-group"
  subnet_ids = [
    var.subnet_private_a_id,
    var.subnet_private_b_id
  ]

  lifecycle {
    create_before_destroy = true
  }
}
