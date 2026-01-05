output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.resume_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.resume_distribution.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.resume_distribution.domain_name
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_apigatewayv2_api.resume_api.api_endpoint
}