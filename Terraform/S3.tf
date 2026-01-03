# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
# https://medium.com/@frankpromiseedah/hosting-a-static-website-on-aws-s3-using-terraform-e12addd22d18

resource "aws_s3_bucket" "s3-terraform" {
  bucket = "s3-terraform-${var.accID}"

  tags = {
    Name    = "s3-terraform"
    Project = "resume"
  }
}

resource "aws_s3_bucket_versioning" "s3-terraform_versioning" {
  bucket = aws_s3_bucket.s3-terraform.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-terraform_encryption" {
  bucket = aws_s3_bucket.s3-terraform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3-terraform_access_block" {
  bucket = aws_s3_bucket.s3-terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object-upload-html" {
  for_each     = fileset("../html/", "*.html")
  bucket       = aws_s3_bucket.s3-terraform.bucket
  key          = each.value
  source       = "../html/${each.value}"
  content_type = "text/html"
  etag         = filemd5("../html/${each.value}")
}

resource "aws_s3_object" "object-upload-css" {
  for_each     = fileset("../html/", "*.css")
  bucket       = aws_s3_bucket.s3-terraform.bucket
  key          = each.value
  source       = "../html/${each.value}"
  content_type = "text/css"
  etag         = filemd5("../html/${each.value}")
}



