# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "resume-oac-s3"
  description                       = "OAC for resume S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ACM Certificate
data "aws_acm_certificate" "domain_cert" {
  domain      = "*.${var.root_domain_name}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# CloudFront Distribution
# tfsec:ignore:aws-cloudfront-enable-waf
resource "aws_cloudfront_distribution" "resume_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["resume.${var.root_domain_name}"]

  default_root_object = "index.html"

  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "s3-resume-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.resume_oac.id

    s3_origin_config {
      origin_access_identity = ""
    } 
  }

  origin {
    domain_name = replace(
      aws_apigatewayv2_api.resume_api.api_endpoint,  
      "https://",  // remove https from the domain name, as CloudFront expects only the domain part
      ""
    )  
      origin_id   = "api-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "api-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-resume-origin"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class  = "PriceClass_100"
  http_version = "http2and3"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.domain_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name    = "cloudfront"
    Project = "resume"
  }
}

# S3 bucket policy for CloudFront
data "aws_iam_policy_document" "s3_allow_cloudfront_oac" {
  statement {
    sid     = "AllowCloudFrontOAC"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${var.s3_bucket_arn}/*"
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
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_allow_cloudfront_oac.json
}

# API Gateway
resource "aws_apigatewayv2_api" "resume_api" {
  name          = "resume-api"
  protocol_type = "HTTP"
}

# Lambda integrations
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.resume_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var. resume_lambda_invoke_arn_alias
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration_likes" {
  api_id                 = aws_apigatewayv2_api.resume_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.likes_lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration_pdf" {
  api_id                 = aws_apigatewayv2_api.resume_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.pdf_lambda_invoke_arn
  payload_format_version = "2.0"
}

# API Routes
resource "aws_apigatewayv2_route" "counter_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "GET /api/view"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "likes_put_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "PUT /api/likes"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_likes.id}"
}

resource "aws_apigatewayv2_route" "likes_get_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "GET /api/likes"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_likes.id}"
}

resource "aws_apigatewayv2_route" "pdf_get_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "GET /api/pdf"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_pdf.id}"
}

# Lambda permissions
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.resume_lambda_function_name
  qualifier     = var.resume_lambda_alias_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_likes" {
  statement_id  = "AllowAPIGatewayInvokelikes"
  action        = "lambda:InvokeFunction"
  function_name = var.likes_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_pdf" {
  statement_id  = "AllowAPIGatewayInvokelikes"
  action        = "lambda:InvokeFunction"
  function_name = var.pdf_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_api.execution_arn}/*/*"
}

# CloudWatch logs
resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/resume"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.resume_api.id
  name        = "$default"
  auto_deploy = true

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