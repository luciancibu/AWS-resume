variable "root_domain_name" {
  description = "Root domain name"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  type        = string
}

variable "s3_bucket_id" {
  description = "ID of the S3 bucket"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "resume_lambda_invoke_arn" {
  description = "Invoke ARN of the resume Lambda function"
  type        = string
}

variable "likes_lambda_invoke_arn" {
  description = "Invoke ARN of the likes Lambda function"
  type        = string
}

variable "resume_lambda_function_name" {
  description = "Name of the resume Lambda function"
  type        = string
}

variable "likes_lambda_function_name" {
  description = "Name of the likes Lambda function"
  type        = string
}

variable "resume_lambda_alias_name" {
  description = "Name of the Lambda alias"
  type        = string
}