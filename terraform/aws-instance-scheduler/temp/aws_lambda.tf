resource "aws_lambda_function" "main" {
  code_signing_config_arn = {
    S3Bucket = join("", ["solutions-", data.aws_region.current.name])
    S3Key    = "aws-instance-scheduler/v1.4.1/instance-scheduler.zip"
  }
  role        = aws_iam_role.scheduler_role.arn
  description = "EC2 and RDS instance scheduler, version v1.4.1"
  environment {
    variables = {
      SCHEDULER_FREQUENCY            = var.scheduler_frequency
      TAG_NAME                       = var.tag_name
      LOG_GROUP                      = aws_scheduler_schedule_group.scheduler_log_group.id
      ACCOUNT                        = data.aws_caller_identity.current.account_id
      ISSUES_TOPIC_ARN               = aws_sns_topic.instance_scheduler_sns_topic.id
      STACK_NAME                     = local.stack_name
      BOTO_RETRY                     = "5,10,30,0.25"
      ENV_BOTO_RETRY_LOGGING         = "FALSE"
      SEND_METRICS                   = local.mappings["mappings"]["TrueFalse"][local.mappings["Send"]["AnonymousUsage"]["Data"]]
      SOLUTION_ID                    = local.mappings["mappings"]["Settings"]["MetricsSolutionId"]
      TRACE                          = local.mappings["mappings"]["TrueFalse"][var.trace]
      ENABLE_SSM_MAINTENANCE_WINDOWS = local.mappings["mappings"]["TrueFalse"][var.enable_ssm_maintenance_windows]
      USER_AGENT                     = join("", ["InstanceScheduler-", local.stack_name, "-v1.4.1"])
      USER_AGENT_EXTRA               = "AwsSolution/SO0030/v1.4.1"
      METRICS_URL                    = local.mappings["mappings"]["Settings"]["MetricsUrl"]
      STACK_ID                       = local.stack_id
      UUID_KEY                       = local.mappings["Send"]["ParameterKey"]["UniqueId"]
      START_EC2_BATCH_SIZE           = "5"
      DDB_TABLE_NAME                 = aws_dynamodb_table.state_table.arn
      CONFIG_TABLE                   = aws_dynamodb_table.config_table.arn
      MAINTENANCE_WINDOW_TABLE       = aws_dynamodb_table.maintenance_window_table.arn
      STATE_TABLE                    = aws_dynamodb_table.state_table.arn
    }
  }
  function_name = join("", [local.stack_name, "-InstanceSchedulerMain"])
  handler       = "main.lambda_handler"
  memory_size   = var.memory_size
  runtime       = "python3.7"
  timeout       = 300
  tracing_config = {
    Mode = "Active"
  }
}

resource "aws_lambda_permission" "instanceschedulerlambda_lambda_function_aws_events_lambda_invoke_permission1_f8_e87_df9" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_ses_receipt_rule_set.scheduler_rule.arn
}
