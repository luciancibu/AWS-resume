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

resource "aws_s3_bucket_website_configuration" "resume-lucian-cibu-s3-terraform" {
  bucket = aws_s3_bucket.resume-lucian-cibu-s3-terraform.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.resume-lucian-cibu-s3-terraform.id
  policy = data.aws_iam_policy_document.iam-ss3-bucket-resume-terraform.json
}
data "aws_iam_policy_document" "iam-ss3-bucket-resume-terraform" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::resume-lucian-cibu-s3-terraform",
      "arn:aws:s3:::resume-lucian-cibu-s3-terraform/*",
    ]
    actions = ["S3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  depends_on = [aws_s3_bucket_public_access_block.resume-lucian-cibu-s3-terraform_access_block]
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
  content_type = "text/css "
  etag         = filemd5("../html/${each.value}")
}



