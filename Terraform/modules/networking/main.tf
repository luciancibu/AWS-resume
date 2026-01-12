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
    domain_name = "${aws_api_gateway_rest_api.resume_api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = "api-origin"
    origin_path = "/prod"

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
      headers      = ["x-api-key"]
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

### Rest API
resource "aws_api_gateway_rest_api" "resume_api" {
  name = "resume-api"
}

# /api
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
  path_part   = "api"
}

# /api/view
resource "aws_api_gateway_resource" "view" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "view"
}

# /api/likes
resource "aws_api_gateway_resource" "likes" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "likes"
}

# /api/pdf
resource "aws_api_gateway_resource" "pdf" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "pdf"
}

# Methods
resource "aws_api_gateway_method" "view_get" {
  rest_api_id      = aws_api_gateway_rest_api.resume_api.id
  resource_id      = aws_api_gateway_resource.view.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "likes_get" {
  rest_api_id      = aws_api_gateway_rest_api.resume_api.id
  resource_id      = aws_api_gateway_resource.likes.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "likes_put" {
  rest_api_id      = aws_api_gateway_rest_api.resume_api.id
  resource_id      = aws_api_gateway_resource.likes.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "pdf_get" {
  rest_api_id      = aws_api_gateway_rest_api.resume_api.id
  resource_id      = aws_api_gateway_resource.pdf.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# view → Lambda ALIAS
resource "aws_api_gateway_integration" "view_lambda" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.view.id
  http_method = aws_api_gateway_method.view_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.resume_lambda_invoke_arn_alias
}

# likes → Lambda
resource "aws_api_gateway_integration" "likes_get_lambda" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.likes.id
  http_method = aws_api_gateway_method.likes_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.likes_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "likes_put_lambda" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.likes.id
  http_method = aws_api_gateway_method.likes_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.likes_lambda_invoke_arn
}

# pdf → Lambda
resource "aws_api_gateway_integration" "pdf_lambda" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.pdf.id
  http_method = aws_api_gateway_method.pdf_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.pdf_lambda_invoke_arn
}

# deploy/stage
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id

  depends_on = [
    aws_api_gateway_integration.view_lambda,
    aws_api_gateway_integration.likes_get_lambda,
    aws_api_gateway_integration.likes_put_lambda,
    aws_api_gateway_integration.pdf_lambda
  ]
}

# tfsec:ignore:aws-api-gateway-enable-access-logging
# tfsec:ignore:aws-api-gateway-enable-tracing
resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
}

# lambda permissions
resource "aws_lambda_permission" "allow_apigw_view" {
  statement_id  = "AllowAPIGatewayInvokeView"
  action        = "lambda:InvokeFunction"
  function_name = var.resume_lambda_function_name
  qualifier     = var.resume_lambda_alias_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_likes" {
  statement_id  = "AllowAPIGatewayInvokeLikes"
  action        = "lambda:InvokeFunction"
  function_name = var.likes_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_pdf" {
  statement_id  = "AllowAPIGatewayInvokePdf"
  action        = "lambda:InvokeFunction"
  function_name = var.pdf_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*"
}

# Api key + usage plan
resource "aws_api_gateway_api_key" "resume_key" {
  name    = "resume-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "resume_plan" {
  name = "resume-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.resume_api.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "resume_key_attach" {
  key_id        = aws_api_gateway_api_key.resume_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.resume_plan.id
}

# Cloudfront Function to add API key header
resource "aws_cloudfront_function" "add_api_key" {
  name    = "add-api-key"
  runtime = "cloudfront-js-1.0"

  code = <<EOF
function handler(event) {
  var request = event.request;

  request.headers['x-api-key'] = {
    value: '0JAbw2U8fI4nz2vbNCQ3O2uwJUJK1SRr4rJhMsfh'
  };

  return request;
}
EOF
}
 