# S3 Bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = "s3-terraform-${var.account_id}"

  tags = {
    Name    = "s3-terraform"
    Project = "resume"
  }
}

# tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Disabled"
  }
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "website_encryption" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website_access_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Terraform state
resource "aws_s3_bucket" "tfstate" {
  bucket = "s3-tfstate-${var.account_id}"

  tags = {
    Name    = "s3-tfstate"
    Project = "resume"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encryption" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_block_public" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for pdf file
resource "aws_s3_bucket" "pdf_bucket" {
  bucket = "s3-pdf-${var.account_id}"

  tags = {
    Name    = "s3-pdf"
    Project = "resume"
  }
}

# tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket_versioning" "pdf_bucket_versioning" {
  bucket = aws_s3_bucket.pdf_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "pdf_bucket_encryption" {
  bucket = aws_s3_bucket.pdf_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pdf_bucket_block_public" {
  bucket = aws_s3_bucket.pdf_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table
# tfsec:ignore:aws-dynamodb-enable-at-rest-encryption
resource "aws_dynamodb_table" "resume_table" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name    = var.table_name
    Project = "resume"
  }
}