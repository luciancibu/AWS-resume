variable "notification_email" {
  description = "Email address for notifications"
  type        = string
}

variable "rollback_lambda_arn" {
  description = "ARN of the rollback Lambda function"
  type        = string
}

variable "rollback_lambda_function_name" {
  description = "Name of the rollback Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the main Lambda function"
  type        = string
}