output "resume_sns_topic_arn" {
  description = "ARN of the resume SNS topic"
  value       = aws_sns_topic.resume_sns_topic.arn
}

output "rollback_sns_topic_arn" {
  description = "ARN of the rollback SNS topic"
  value       = aws_sns_topic.lambda_rollback.arn
}