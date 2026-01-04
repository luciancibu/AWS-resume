# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
# https://medium.com/@frankpromiseedah/hosting-a-static-website-on-aws-s3-using-terraform-e12addd22d18

# Reason: personal project, logging not needed
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "s3-terraform" {
  bucket = "s3-terraform-${var.accID}"

  tags = {
    Name    = "s3-terraform"
    Project = "resume"
  }
}

# Reason: personal project, versioning not needed
# tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket_versioning" "s3-terraform_versioning" {
  bucket = aws_s3_bucket.s3-terraform.id
  versioning_configuration {
    status = "Disabled"
  }

}
# Reason: personal project, AWS-managed key is sufficient
# tfsec:ignore:aws-s3-encryption-customer-key
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

## tfstate bucket ##

# Reason: personal project, logging not needed
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "s3_tfstate" {
  bucket = "s3-tfstate-${var.accID}"

  tags = {
    Name    = "s3-tfstate"
    Project = "resume"
  }
}

resource "aws_s3_bucket_versioning" "s3_tfstate_versioning" {
  bucket = aws_s3_bucket.s3_tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Reason: personal project, AWS-managed key is sufficient
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_tfstate_encryption" {
  bucket = aws_s3_bucket.s3_tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_tfstate_block_public" {
  bucket = aws_s3_bucket.s3_tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
