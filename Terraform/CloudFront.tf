# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution

resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "resume-oac-s3"
  description                       = "OAC for resume S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_acm_certificate" "lucian-cibu-xyz" {
  domain      = "*.${var.rootDomainName}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# Reason: personal project, WAF and logging not needed
# tfsec:ignore:aws-cloudfront-enable-waf
# tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "resume_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["resume.${var.rootDomainName}"]

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.s3-terraform.bucket_regional_domain_name
    origin_id   = "s3-resume-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.resume_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
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
    acm_certificate_arn      = data.aws_acm_certificate.lucian-cibu-xyz.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name    = "cloudfront"
    Project = "resume"
  }
}
