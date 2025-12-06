# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/account_region

provider "aws" {
  region  = var.region
  profile = "default"
}