# SNS Topics
# tfsec:ignore:aws-sns-topic-encryption-use-cmk
resource "aws_sns_topic" "resume_sns_topic" {
  name              = "SNS-resume"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "resume_email_sub" {
  topic_arn = aws_sns_topic.resume_sns_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

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

# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic_subscription" "lambda_rollback_email" {
  topic_arn = aws_sns_topic.lambda_rollback.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_subscription" "rollback_sub" {
  topic_arn = aws_sns_topic.lambda_rollback.arn
  protocol  = "lambda"
  endpoint  = var.rollback_lambda_arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSTriggerRollback"
  action        = "lambda:InvokeFunction"
  function_name = var.rollback_lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambda_rollback.arn
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_prod_errors" {
  alarm_name = "lambda-prod-errors"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  statistic   = "Sum"

  period              = 20
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = var.lambda_function_name
    Resource     = "${var.lambda_function_name}:prod"
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.lambda_rollback.arn
  ]
}