resource "aws_apigatewayv2_api" "resume_api" {
  name          = "resume-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "PUT", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.resume_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_alias.prod.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "counter_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "GET /view"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume_lambda.function_name
  qualifier     = aws_lambda_alias.prod.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_api.execution_arn}/*/*"
}

## Lambda Integration for likes
resource "aws_apigatewayv2_integration" "lambda_integration_likes" {
  api_id                 = aws_apigatewayv2_api.resume_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.resume_lambda_likes.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "likes_put_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "PUT /likes"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_likes.id}"
}

resource "aws_apigatewayv2_route" "likes_get_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "GET /likes"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_likes.id}"
}

resource "aws_lambda_permission" "allow_apigw_likes" {
  statement_id  = "AllowAPIGatewayInvokelikes"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume_lambda_likes.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/resume"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.resume_api.id
  name        = "$default"
  auto_deploy = true

  # CloudWatch logs
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format = jsonencode({
      requestId = "$context.requestId"
      status    = "$context.status"
      ip        = "$context.identity.sourceIp"
      routeKey  = "$context.routeKey"
    })
  }
}





