# resource "aws_scheduler_schedule_group" "scheduler_log_group" {
#   name = join("", [local.stack_name, "-logs"])
#   // CF Property(RetentionInDays) = var.log_retention_days
# }

# resource "aws_ses_receipt_rule_set" "scheduler_rule" {
#   // CF Property(Description) = "Instance Scheduler - Rule to trigger instance for scheduler function version v1.4.1"
#   // CF Property(ScheduleExpression) = local.mappings["mappings"]["Timeouts"][var.scheduler_frequency]
#   // CF Property(State) = local.mappings["mappings"]["EnabledDisabled"][var.scheduling_active]
#   // CF Property(Targets) = [
#   //   {
#   //     Arn = aws_lambda_function.main.arn
#   //     Id = "Target0"
#   //   }
#   // ]
# }

# resource "aws_directory_service_shared_directory" "scheduler_config_helper" {
#   // CF Property(ServiceToken) = aws_lambda_function.main.arn
#   // CF Property(timeout) = 120
#   // CF Property(config_table) = aws_dynamodb_table.config_table.arn
#   // CF Property(tagname) = var.tag_name
#   // CF Property(default_timezone) = var.default_timezone
#   // CF Property(use_metrics) = local.mappings["mappings"]["TrueFalse"][var.use_cloud_watch_metrics]
#   // CF Property(scheduled_services) = split("","", local.mappings["mappings"]["Services"][var.scheduled_services])
#   // CF Property(schedule_clusters) = local.mappings["mappings"]["TrueFalse"][var.schedule_rds_clusters]
#   // CF Property(create_rds_snapshot) = local.mappings["mappings"]["TrueFalse"][var.create_rds_snapshot]
#   // CF Property(regions) = var.regions
#   // CF Property(cross_account_roles) = var.cross_account_roles
#   // CF Property(schedule_lambda_account) = local.mappings["mappings"]["TrueFalse"][var.schedule_lambda_account]
#   // CF Property(trace) = local.mappings["mappings"]["TrueFalse"][var.trace]
#   // CF Property(enable_SSM_maintenance_windows) = local.mappings["mappings"]["TrueFalse"][var.enable_ssm_maintenance_windows]
#   // CF Property(log_retention_days) = var.log_retention_days
#   // CF Property(started_tags) = var.started_tags
#   // CF Property(stopped_tags) = var.stopped_tags
#   // CF Property(stack_version) = "v1.4.1"
# }
