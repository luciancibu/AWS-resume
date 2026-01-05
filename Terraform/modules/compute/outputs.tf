output "resume_lambda_function_name" {
  description = "Name of the main resume Lambda function"
  value       = aws_lambda_function.resume_lambda.function_name
}

output "resume_lambda_arn" {
  description = "ARN of the main resume Lambda function"
  value       = aws_lambda_function.resume_lambda.arn
}

output "resume_lambda_invoke_arn" {
  description = "Invoke ARN of the main resume Lambda function"
  value       = aws_lambda_function.resume_lambda.invoke_arn
}

output "likes_lambda_function_name" {
  description = "Name of the likes Lambda function"
  value       = aws_lambda_function.resume_lambda_likes.function_name
}

output "likes_lambda_arn" {
  description = "ARN of the likes Lambda function"
  value       = aws_lambda_function.resume_lambda_likes.arn
}

output "likes_lambda_invoke_arn" {
  description = "Invoke ARN of the likes Lambda function"
  value       = aws_lambda_function.resume_lambda_likes.invoke_arn
}

output "rollback_lambda_arn" {
  description = "ARN of the rollback Lambda function"
  value       = aws_lambda_function.rollback_lambda.arn
}