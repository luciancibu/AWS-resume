# Provider Configuration
# AWS provider and data sources for current region and account
provider "aws" {
  region = var.region
}

# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}