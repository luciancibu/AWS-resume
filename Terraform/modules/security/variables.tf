variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}