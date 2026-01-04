# Reason: personal project, AWS-managed key is sufficient
# tfsec:ignore:aws-sns-topic-encryption-use-cmk
resource "aws_sns_topic" "resume_sns_topic" {
  name              = "SNS-resume"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "resume_email_sub" {
  topic_arn = aws_sns_topic.resume_sns_topic.arn
  protocol  = "email"
  endpoint  = "luciancibu@yahoo.com"
}


# Reason: personal project, AWS-managed key is sufficient
# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "lambda_rollback" {
  name = "lambda-rollback-topic"
}

resource "aws_sns_topic_policy" "lambda_rollback_policy" {
  arn = aws_sns_topic.lambda_rollback.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.lambda_rollback.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "lambda_rollback_email" {
  topic_arn = aws_sns_topic.lambda_rollback.arn
  protocol  = "email"
  endpoint  = "luciancibu@yahoo.com"
}


# Rollback lambda subscriptiuon
resource "aws_sns_topic_subscription" "rollback_sub" {
  topic_arn = aws_sns_topic.lambda_rollback.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.rollback_lambda.arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSTriggerRollback"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rollback_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambda_rollback.arn
}
