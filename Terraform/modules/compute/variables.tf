variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "rollback_lambda_role_arn" {
  description = "ARN of the rollback Lambda execution role"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "stable_lambda_version" {
  description = "Stable Lambda version for rollback"
  type        = string
}

variable "lambda_source_path" {
  description = "Path to the main Lambda function source"
  type        = string
}

variable "likes_lambda_source_path" {
  description = "Path to the likes Lambda function source"
  type        = string
}

variable "rollback_lambda_source_path" {
  description = "Path to the rollback Lambda function source"
  type        = string
}

variable "pdf_lambda_source_path" {
  description = "Path to the PDF Lambda function source"
  type        = string
}