resource "aws_cloudwatch_metric_alarm" "lambda_prod_errors" {
  alarm_name = "lambda-prod-errors"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  statistic   = "Sum"

  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.resume_lambda.function_name
    Resource     = "${aws_lambda_function.resume_lambda.function_name}:${aws_lambda_alias.prod.name}"
  }

  treat_missing_data = "notBreaching"
  # notBreaching -> treat missing data as "OK" (no alarm when no data is available)
  # breaching    -> treat missing data as "ALARM" (alarm triggers if no data is available)
  # ignore       -> ignore missing data when evaluating the alarm
  # missing      -> keep alarm state as INSUFFICIENT_DATA when data is missing

  alarm_actions = [
    aws_sns_topic.lambda_rollback.arn
  ]
}
