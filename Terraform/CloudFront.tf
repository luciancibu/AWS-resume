# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution

data "aws_acm_certificate" "lucian-cibu-xyz" {
  domain      = "*.${var.rootDomainName}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_cloudfront_distribution" "resume_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["resume.${var.rootDomainName}"]

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket_website_configuration.resume-lucian-cibu-s3-terraform.website_endpoint
    origin_id   = "s3-resume-origin-terraform"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

default_cache_behavior {
  allowed_methods  = ["GET", "HEAD"]
  cached_methods   = ["GET", "HEAD"]
  target_origin_id = "s3-resume-origin-terraform"

  forwarded_values {
    query_string = false

    cookies {
      forward = "none"
    }
  }
     compress = true  
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400  
}


  http_version = "http2and3"
  price_class  = "PriceClass_100"

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
    Name   = "resume-lucian-cibu-CloudFront-terraform"
    Project = "resume-lucian-cibu"
  }
}
