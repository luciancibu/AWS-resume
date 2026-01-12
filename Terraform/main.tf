# Terraform Configuration
# This file defines the required providers and their versions
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}



# Storage Module - S3 buckets and DynamoDB table
module "storage" {
  source = "./modules/storage"

  account_id = var.account_id
  table_name = var.table_name
}

# Monitoring Module - CloudWatch alarms and SNS topics
module "monitoring" {
  source = "./modules/monitoring"

  notification_email            = var.notification_email
  rollback_lambda_arn           = module.compute.rollback_lambda_arn
  rollback_lambda_function_name = "lambda-rollback-handler"
  lambda_function_name          = module.compute.resume_lambda_function_name
}

# Security Module - IAM roles and policies
module "security" {
  source = "./modules/security"

  region             = var.region
  account_id         = var.account_id
  pdf_file_name      = var.pdf_file_name
  dynamodb_table_arn = module.storage.dynamodb_table_arn
  sns_topic_arn      = module.monitoring.resume_sns_topic_arn
  pdf_bucket_name    = module.storage.pdf_bucket_name
}

# Compute Module - Lambda functions with versioning
module "compute" {
  source = "./modules/compute"

  lambda_role_arn             = module.security.lambda_role_arn
  pdf_lambda_role_arn         = module.security.pdf_lambda_role_arn
  rollback_lambda_role_arn    = module.security.rollback_lambda_role_arn
  dynamodb_table_name         = module.storage.dynamodb_table_name
  sns_topic_arn               = module.monitoring.resume_sns_topic_arn
  stable_lambda_version       = var.stable_lambda_version
  pdf_file_name               = var.pdf_file_name
  pdf_bucket_name             = module.storage.pdf_bucket_name
  lambda_source_path          = "../Lambda/lambda_function.py"
  likes_lambda_source_path    = "../Lambda/lambda_likes.py"
  rollback_lambda_source_path = "../Lambda/lambda_rollback.py"
  pdf_lambda_source_path      = "../Lambda/lambda_pdf.py"
}

# Networking Module - CloudFront, API Gateway, and S3 policies
module "networking" {
  source = "./modules/networking"

  region                         = var.region
  root_domain_name               = var.root_domain_name
  api_gateway_api_key            = var.api_gateway_api_key
  s3_bucket_domain_name          = module.storage.website_bucket_domain_name
  s3_bucket_id                   = module.storage.website_bucket_id
  s3_bucket_arn                  = module.storage.website_bucket_arn
  resume_lambda_alias_name       = module.compute.resume_lambda_alias_name
  resume_lambda_invoke_arn_alias = module.compute.resume_lambda_invoke_arn_alias
  likes_lambda_invoke_arn        = module.compute.likes_lambda_invoke_arn
  resume_lambda_function_name    = module.compute.resume_lambda_function_name
  likes_lambda_function_name     = module.compute.likes_lambda_function_name
  pdf_lambda_function_name       = module.compute.pdf_lambda_function_name
  pdf_lambda_invoke_arn          = module.compute.pdf_lambda_invoke_arn
}

# Infrastructure Module - Optional EC2 Jenkins server
module "infrastructure" {
  source = "./modules/infrastructure"

  enable_jenkins       = var.enable_jenkins
  ami_id               = var.ami_id
  availability_zone    = var.availability_zone
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  jenkins_setup_script = "./setup_Jenkins.sh"
}