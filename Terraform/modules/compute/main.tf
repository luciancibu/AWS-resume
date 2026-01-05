# Lambda view counter
data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = var.lambda_source_path
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "resume_lambda" {
  function_name = "lambda-terraform"

  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  role = var.lambda_role_arn

  filename         = data.archive_file.python_lambda_package.output_path
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  timeout = 5
  publish = true

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
      ITEM_ID        = "views"
    }
  }
}

resource "aws_lambda_alias" "prod" {
  name             = "prod"
  function_name    = aws_lambda_function.resume_lambda.function_name
  function_version = aws_lambda_function.resume_lambda.version

  routing_config {
    additional_version_weights = {
      (var.stable_lambda_version) = 0.1
    }
  }
}

# Lambda likes
data "archive_file" "likes_lambda_package" {
  type        = "zip"
  source_file = var.likes_lambda_source_path
  output_path = "${path.module}/lambda_likes.zip"
}

resource "aws_lambda_function" "resume_lambda_likes" {
  function_name = "lambda-terraform-likes"

  handler = "lambda_likes.lambda_handler"
  runtime = "python3.12"

  role = var.lambda_role_arn

  filename         = data.archive_file.likes_lambda_package.output_path
  source_code_hash = data.archive_file.likes_lambda_package.output_base64sha256

  timeout = 5
  publish = false

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      ITEM_ID        = "likes"
    }
  }
}

# Lambda rollback
data "archive_file" "rollback_lambda_package" {
  type        = "zip"
  source_file = var.rollback_lambda_source_path
  output_path = "${path.module}/lambda_rollback.zip"
}

resource "aws_lambda_function" "rollback_lambda" {
  function_name = "lambda-rollback-handler"
  runtime       = "python3.12"
  handler       = "lambda_rollback.lambda_handler"
  role          = var.rollback_lambda_role_arn

  filename         = data.archive_file.rollback_lambda_package.output_path
  source_code_hash = data.archive_file.rollback_lambda_package.output_base64sha256

  environment {
    variables = {
      TARGET_FUNCTION_NAME = aws_lambda_function.resume_lambda.function_name
      ALIAS_NAME           = aws_lambda_alias.prod.name
      STABLE_VERSION       = var.stable_lambda_version
    }
  }
}