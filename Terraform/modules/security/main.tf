# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy-terraform"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/*"
      },
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Rollback Lambda role
resource "aws_iam_role" "rollback_lambda_role" {
  name = "rollback-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "rollback_lambda_policy" {
  role = aws_iam_role.rollback_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:GetAlias",
          "lambda:UpdateAlias"
        ]
        Resource = [
          "arn:aws:lambda:${var.region}:${var.account_id}:function:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

