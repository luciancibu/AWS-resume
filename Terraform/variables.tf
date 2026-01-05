# Root-level Variables
# These variables are used across all modules

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0ecb62995f68bb549"
}

variable "root_domain_name" {
  description = "Root domain name"
  type        = string
  default     = "lucian-cibu.xyz"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "dynamodb-terraform"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "083971419667"
}

variable "stable_lambda_version" {
  description = "Stable Lambda version for rollback"
  type        = string
  default     = "16"
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = "luciancibu@yahoo.com"
}

variable "enable_jenkins" {
  description = "Whether to create Jenkins EC2 instance"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "188.24.56.231/32"
}

variable "pdf_file_name" {
  description = "Name of the PDF file in the S3 bucket"
  type        = string
  default     = "lucian_cibu_resume.pdf"
}