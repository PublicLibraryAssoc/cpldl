resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_blocks
  enable_dns_hostnames = true

  tags = {
    environment = var.environment_name
  }
}
