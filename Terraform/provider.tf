# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/account_region

provider "aws" {
  region = var.region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}