terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "digitallearn-ops-staging"
    key    = "terraform_state"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../modules/vpc"

  environment_name = var.environment_name
  region           = var.region
}

module "database" {
  source = "../modules/database"

  environment_name = var.environment_name
  vpc_id           = module.vpc.vpc_id
  db_subnet_a_id   = module.vpc.db_subnet_a_id
  db_subnet_b_id   = module.vpc.db_subnet_b_id
  db_username      = var.db_username
  db_password      = var.db_password
}

# Security groups
# Database
# S3
# Load balancer
# ECS application cluster
# ECS sidekiq cluster
# Elasticache redis
