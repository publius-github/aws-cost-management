resource "aws_cloudwatch_event_rule" "trigger" {
  name = "${var.name_prefix}-ami-cleaner-lambda-trigger"
  description = "Triggers that fires the lambda function"
  schedule_expression = "cron(0 0 1 * ? *)"
  tags = var.tags
}


resource "aws_cloudwatch_event_target" "clean_amis" {
  rule = aws_cloudwatch_event_rule.trigger.name
  arn = aws_lambda_function.ami_cleaner.arn
  input = jsonencode({
    ami_tags_to_check= {
     "Environment"="UAT"
     "Application"="MyApp"
    }
    regions = ["us-east-2", "eu-west-1"]
    max_ami_age_to_prevent_deletion = 7
  })
}
