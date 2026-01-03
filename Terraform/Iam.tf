# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role_terraform" {
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

resource "aws_iam_role_policy" "lambda_policy_terraform" {
  name = "lambda-policy-terraform"
  role = aws_iam_role.lambda_role_terraform.id

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
        Resource = "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.tableName}"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.resume_lambda.function_name}:*"
      }
    ]
  })
}

data "aws_iam_policy_document" "s3_allow_cloudfront_oac" {
  statement {
    sid     = "AllowCloudFrontOAC"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3-terraform.bucket}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.resume_distribution.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "resume_policy" {
  bucket = aws_s3_bucket.s3-terraform.id
  policy = data.aws_iam_policy_document.s3_allow_cloudfront_oac.json
}