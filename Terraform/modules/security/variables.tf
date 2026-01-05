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

variable "pdf_bucket_name" {
  description = "Name of the S3 bucket for PDF files"
  type        = string
}

variable "pdf_file_name" {
  description = "Name of the PDF file in the S3 bucket"
  type        = string
}