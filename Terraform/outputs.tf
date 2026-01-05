# Root-level Outputs
# These outputs provide key information about the deployed infrastructure

output "website_url" {
  description = "Website URL"
  value       = "https://resume.${var.root_domain_name}"
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.networking.api_gateway_url
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = module.networking.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.networking.cloudfront_distribution_id
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.storage.website_bucket_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.storage.dynamodb_table_name
}

output "jenkins_public_ip" {
  description = "Jenkins public IP (if enabled)"
  value       = module.infrastructure.jenkins_public_ip
}