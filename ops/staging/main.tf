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

  environment_name    = var.environment_name
  subnet_private_a_id = module.vpc.subnet_private_a_id
  subnet_private_b_id = module.vpc.subnet_private_b_id
}

# Security groups
# Database
# S3
# Load balancer
# ECS application cluster
# ECS sidekiq cluster
# Elasticache redis
