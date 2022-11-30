resource "aws_lambda_function" "ami_cleaner" {
  filename = "${path.module}/lambda.zip"
  function_name = "ami-cleaner-lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.8"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags = var.tags

  environment {
    variables = {
      sns_topic_arn = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ami_cleaner" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_cleaner.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:<region>:<account_id>:rule/ami-cleaner-lambda-trigger*"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}
