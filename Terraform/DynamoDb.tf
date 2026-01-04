# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table

resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name         = var.tableName
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery { # table backup for 35 fays
    enabled = true
  }

  tags = {
    Name        = "dynamodb-terraform"
    Environment = "resume"
  }
}

resource "aws_dynamodb_table_item" "resume_views_item" {
  table_name = aws_dynamodb_table.basic_dynamodb_table.name
  hash_key   = "id"

  item = jsonencode({
    id    = { S = "views" }
    views = { N = "0" }
  })
}

resource "aws_dynamodb_table_item" "resume_likes_item" {
  table_name = aws_dynamodb_table.basic_dynamodb_table.name
  hash_key   = "id"

  item = jsonencode({
    id           = { S = "likes" }
    likes_number = { N = "0" }
  })
}


