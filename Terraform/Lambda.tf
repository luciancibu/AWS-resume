# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
# https://medium.com/@haissamhammoudfawaz/create-a-aws-lambda-function-using-terraform-and-python-4e0c2816753a

# Lambda view counter
data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "../Lambda/lambda_function.py"
  output_path = "${path.module}/Lambda.zip"
}

resource "aws_lambda_function" "resume_lambda" {
  function_name = "lambda-terraform"

  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  role = aws_iam_role.lambda_role_terraform.arn

  filename         = data.archive_file.python_lambda_package.output_path
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  timeout = 5
  publish = true // versioning

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.basic_dynamodb_table.name
      SNS_TOPIC_ARN  = aws_sns_topic.resume_sns_topic.arn
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
      (var.stable_lambda_version) = 0.9
    }
  }
}

# Lambda Rollback Function
resource "aws_lambda_function" "rollback_lambda" {
  function_name = "lambda-rollback-handler"
  runtime       = "python3.12"
  handler       = "lambda_rollback.lambda_handler"
  role          = aws_iam_role.rollback_lambda_role.arn

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

data "archive_file" "rollback_lambda_package" {
  type        = "zip"
  source_file = "../Lambda/lambda_rollback.py"
  output_path = "${path.module}/lambda_rollback.zip"
}

# Lambda likes
resource "aws_lambda_function" "resume_lambda_likes" {
  function_name = "lambda-terraform-likes"

  handler = "lambda_likes.lambda_handler"
  runtime = "python3.12"

  role = aws_iam_role.lambda_role_terraform.arn

  filename         = data.archive_file.likes_lambda_package.output_path
  source_code_hash = data.archive_file.likes_lambda_package.output_base64sha256

  timeout = 5
  publish = false // versioning

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.basic_dynamodb_table.name
      ITEM_ID        = "views"
    }
  }
}

# resource "aws_lambda_alias" "prod_likes" {
#   name             = "prod"
#   function_name    = aws_lambda_function.resume_lambda_likes.function_name
#   function_version = aws_lambda_function.resume_lambda_likes.version

#   # routing_config {
#   #   additional_version_weights = {
#   #     (var.stable_lambda_version) = 0.9
#   #   }
#   # }
# }

data "archive_file" "likes_lambda_package" {
  type        = "zip"
  source_file = "../Lambda/lambda_likes.py"
  output_path = "${path.module}/lambda_likes.zip"
}

