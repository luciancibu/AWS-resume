output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "rollback_lambda_role_arn" {
  description = "ARN of the rollback Lambda execution role"
  value       = aws_iam_role.rollback_lambda_role.arn
}

output "pdf_lambda_role_arn" {
  description = "ARN of the PDF Lambda execution role"
  value       = aws_iam_role.pdf_lambda_role.arn
}
