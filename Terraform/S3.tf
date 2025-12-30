# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
# https://medium.com/@frankpromiseedah/hosting-a-static-website-on-aws-s3-using-terraform-e12addd22d18

resource "aws_s3_bucket" "resume-lucian-cibu-s3-terraform" {
  bucket = "resume-lucian-cibu-s3-terraform"

  tags = {
    Name    = "resume-lucian-cibu-s3-terraform"
    Project = "resume-lucian-cibu"
  }
}


resource "aws_s3_bucket_versioning" "resume-lucian-cibu-s3-terraform_versioning" {
  bucket = aws_s3_bucket.resume-lucian-cibu-s3-terraform.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "resume-lucian-cibu-s3-terraform_access_block" {
  bucket = aws_s3_bucket.resume-lucian-cibu-s3-terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_allow_cloudfront_oac" {
  statement {
    sid     = "AllowCloudFrontOAC"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::resume-lucian-cibu-s3-terraform/*"
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
  bucket = aws_s3_bucket.resume-lucian-cibu-s3-terraform.id
  policy = data.aws_iam_policy_document.s3_allow_cloudfront_oac.json
}


resource "aws_s3_object" "object-upload-html" {
  for_each     = fileset("../html/", "*.html")
  bucket       = aws_s3_bucket.resume-lucian-cibu-s3-terraform.bucket
  key          = each.value
  source       = "../html/${each.value}"
  content_type = "text/html"
  etag         = filemd5("../html/${each.value}")
}

resource "aws_s3_object" "object-upload-css" {
  for_each     = fileset("../html/", "*.css")
  bucket       = aws_s3_bucket.resume-lucian-cibu-s3-terraform.bucket
  key          = each.value
  source       = "../html/${each.value}"
  content_type = "text/css"
  etag         = filemd5("../html/${each.value}")
}



