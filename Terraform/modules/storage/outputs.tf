output "website_bucket_id" {
  description = "ID of the S3 bucket for website"
  value       = aws_s3_bucket.website.id
}

output "website_bucket_arn" {
  description = "ARN of the S3 bucket for website"
  value       = aws_s3_bucket.website.arn
}

output "website_bucket_domain_name" {
  description = "Domain name of the S3 bucket for website"
  value       = aws_s3_bucket.website.bucket_domain_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.resume_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.resume_table.arn
}