# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "resume_lucian_cibu_lambda_role_terraform" {
  name = "resume-lucian-cibu-lambda-role-terraform"

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

resource "aws_iam_role_policy" "resume_lucian_cibu_lambda_policy_terraform" {
  name = "resume-lucian-cibu-lambda-policy-terraform"
  role = aws_iam_role.resume_lucian_cibu_lambda_role_terraform.id

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
      }
    ]
  })
}



