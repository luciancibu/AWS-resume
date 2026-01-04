# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
# https://medium.com/@haissamhammoudfawaz/create-a-aws-lambda-function-using-terraform-and-python-4e0c2816753a

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

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.basic_dynamodb_table.name
      SNS_TOPIC_ARN  = aws_sns_topic.resume_sns_topic.arn
      ITEM_ID        = "views"
    }
  }
}
