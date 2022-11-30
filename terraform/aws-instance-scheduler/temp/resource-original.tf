# resource "aws_scheduler_schedule_group" "scheduler_log_group" {
#   name = join("", [local.stack_name, "-logs"])
#   // CF Property(RetentionInDays) = var.log_retention_days
# }

# resource "aws_iam_role" "scheduler_role" {
#   assume_role_policy = {
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = [
#             "events.amazonaws.com",
#             "lambda.amazonaws.com"
#           ]
#         }
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   path = "/"
# }

# resource "aws_iam_policy" "scheduler_role_default_policy66_f774_b8" {
#   policy = {
#     Statement = [
#       {
#         Action = [
#           "xray:PutTraceSegments",
#           "xray:PutTelemetryRecords"
#         ]
#         Effect = "Allow"
#         Resource = "*"
#       },
#       {
#         Action = [
#           "dynamodb:BatchGetItem",
#           "dynamodb:GetRecords",
#           "dynamodb:GetShardIterator",
#           "dynamodb:Query",
#           "dynamodb:GetItem",
#           "dynamodb:Scan",
#           "dynamodb:ConditionCheckItem",
#           "dynamodb:BatchWriteItem",
#           "dynamodb:PutItem",
#           "dynamodb:UpdateItem",
#           "dynamodb:DeleteItem"
#         ]
#         Effect = "Allow"
#         Resource = [
#           aws_dynamodb_table.state_table.arn,
#           null
#         ]
#       },
#       {
#         Action = [
#           "dynamodb:DeleteItem",
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "dynamodb:Query",
#           "dynamodb:Scan",
#           "dynamodb:BatchWriteItem"
#         ]
#         Effect = "Allow"
#         Resource = [
#           aws_dynamodb_table.config_table.arn,
#           aws_dynamodb_table.maintenance_window_table.arn
#         ]
#       },
#       {
#         Action = [
#           "ssm:PutParameter",
#           "ssm:GetParameter"
#         ]
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/Solutions/aws-instance-scheduler/UUID/*"
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   name = "SchedulerRoleDefaultPolicy66F774B8"
#   // CF Property(Roles) = [
#   //   aws_iam_role.scheduler_role.arn
#   // ]
# }

# resource "aws_kms_key" "instance_scheduler_encryption_key" {
#   policy = {
#     Statement = [
#       {
#         Action = "kms:*"
#         Effect = "Allow"
#         Principal = {
#           AWS = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":root"])
#         }
#         Resource = "*"
#         Sid = "default"
#       },
#       {
#         Action = [
#           "kms:GenerateDataKey*",
#           "kms:Decrypt"
#         ]
#         Effect = "Allow"
#         Principal = {
#           AWS = aws_iam_role.scheduler_role.arn
#         }
#         Resource = "*"
#         Sid = "Allows use of key"
#       },
#       {
#         Action = [
#           "kms:Create*",
#           "kms:Describe*",
#           "kms:Enable*",
#           "kms:List*",
#           "kms:Put*",
#           "kms:Update*",
#           "kms:Revoke*",
#           "kms:Disable*",
#           "kms:Get*",
#           "kms:Delete*",
#           "kms:ScheduleKeyDeletion",
#           "kms:CancelKeyDeletion",
#           "kms:GenerateDataKey",
#           "kms:TagResource",
#           "kms:UntagResource"
#         ]
#         Effect = "Allow"
#         Principal = {
#           AWS = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":root"])
#         }
#         Resource = "*"
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   description = "Key for SNS"
#   is_enabled = True
#   enable_key_rotation = True
# }

# resource "aws_kms_alias" "instance_scheduler_encryption_key_alias" {
#   name = join("", ["alias/", local.stack_name, "-instance-scheduler-encryption-key"])
#   target_key_id = aws_kms_key.instance_scheduler_encryption_key.arn
# }

# resource "aws_sns_topic" "instance_scheduler_sns_topic" {
#   kms_master_key_id = aws_kms_key.instance_scheduler_encryption_key.arn
# }

# resource "aws_iam_role" "instanceschedulerlambda_lambda_function_service_role_ebf44_cd1" {
#   assume_role_policy = {
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   force_detach_policies = [
#     {
#       PolicyDocument = {
#         Statement = [
#           {
#             Action = [
#               "logs:CreateLogGroup",
#               "logs:CreateLogStream",
#               "logs:PutLogEvents"
#             ]
#             Effect = "Allow"
#             Resource = join("", ["arn:", data.aws_partition.current.partition, ":logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":log-group:/aws/lambda/*"])
#           }
#         ]
#         Version = "2012-10-17"
#       }
#       PolicyName = "LambdaFunctionServiceRolePolicy"
#     }
#   ]
# }

# resource "aws_lambda_function" "main" {
#   code_signing_config_arn = {
#     S3Bucket = join("", ["solutions-", data.aws_region.current.name])
#     S3Key = "aws-instance-scheduler/v1.4.1/instance-scheduler.zip"
#   }
#   role = aws_iam_role.scheduler_role.arn
#   description = "EC2 and RDS instance scheduler, version v1.4.1"
#   environment {
#     variables = {
#       SCHEDULER_FREQUENCY = var.scheduler_frequency
#       TAG_NAME = var.tag_name
#       LOG_GROUP = aws_scheduler_schedule_group.scheduler_log_group.id
#       ACCOUNT = data.aws_caller_identity.current.account_id
#       ISSUES_TOPIC_ARN = aws_sns_topic.instance_scheduler_sns_topic.id
#       STACK_NAME = local.stack_name
#       BOTO_RETRY = "5,10,30,0.25"
#       ENV_BOTO_RETRY_LOGGING = "FALSE"
#       SEND_METRICS = local.mappings["mappings"]["TrueFalse"][local.mappings["Send"]["AnonymousUsage"]["Data"]]
#       SOLUTION_ID = local.mappings["mappings"]["Settings"]["MetricsSolutionId"]
#       TRACE = local.mappings["mappings"]["TrueFalse"][var.trace]
#       ENABLE_SSM_MAINTENANCE_WINDOWS = local.mappings["mappings"]["TrueFalse"][var.enable_ssm_maintenance_windows]
#       USER_AGENT = join("", ["InstanceScheduler-", local.stack_name, "-v1.4.1"])
#       USER_AGENT_EXTRA = "AwsSolution/SO0030/v1.4.1"
#       METRICS_URL = local.mappings["mappings"]["Settings"]["MetricsUrl"]
#       STACK_ID = local.stack_id
#       UUID_KEY = local.mappings["Send"]["ParameterKey"]["UniqueId"]
#       START_EC2_BATCH_SIZE = "5"
#       DDB_TABLE_NAME = aws_dynamodb_table.state_table.arn
#       CONFIG_TABLE = aws_dynamodb_table.config_table.arn
#       MAINTENANCE_WINDOW_TABLE = aws_dynamodb_table.maintenance_window_table.arn
#       STATE_TABLE = aws_dynamodb_table.state_table.arn
#     }
#   }
#   function_name = join("", [local.stack_name, "-InstanceSchedulerMain"])
#   handler = "main.lambda_handler"
#   memory_size = var.memory_size
#   runtime = "python3.7"
#   timeout = 300
#   tracing_config = {
#     Mode = "Active"
#   }
# }

# resource "aws_lambda_permission" "instanceschedulerlambda_lambda_function_aws_events_lambda_invoke_permission1_f8_e87_df9" {
#   action = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.main.arn
#   principal = "events.amazonaws.com"
#   source_arn = aws_ses_receipt_rule_set.scheduler_rule.arn
# }

# resource "aws_dynamodb_table" "state_table" {
#   // CF Property(KeySchema) = [
#   //   {
#   //     AttributeName = "service"
#   //     KeyType = "HASH"
#   //   },
#   //   {
#   //     AttributeName = "account-region"
#   //     KeyType = "RANGE"
#   //   }
#   // ]
#   attribute = [
#     {
#       name = "service"
#       type = "S"
#     },
#     {
#       name = "account-region"
#       type = "S"
#     }
#   ]
#   billing_mode = "PAY_PER_REQUEST"
#   point_in_time_recovery = {
#     PointInTimeRecoveryEnabled = True
#   }
#   // CF Property(SSESpecification) = {
#   //   KMSMasterKeyId = aws_kms_key.instance_scheduler_encryption_key.arn
#   //   SSEEnabled = True
#   //   SSEType = "KMS"
#   // }
# }

# resource "aws_dynamodb_table" "config_table" {
#   // CF Property(KeySchema) = [
#   //   {
#   //     AttributeName = "type"
#   //     KeyType = "HASH"
#   //   },
#   //   {
#   //     AttributeName = "name"
#   //     KeyType = "RANGE"
#   //   }
#   // ]
#   attribute = [
#     {
#       name = "type"
#       type = "S"
#     },
#     {
#       name = "name"
#       type = "S"
#     }
#   ]
#   billing_mode = "PAY_PER_REQUEST"
#   point_in_time_recovery = {
#     PointInTimeRecoveryEnabled = True
#   }
#   // CF Property(SSESpecification) = {
#   //   KMSMasterKeyId = aws_kms_key.instance_scheduler_encryption_key.arn
#   //   SSEEnabled = True
#   //   SSEType = "KMS"
#   // }
# }

# resource "aws_dynamodb_table" "maintenance_window_table" {
#   // CF Property(KeySchema) = [
#   //   {
#   //     AttributeName = "Name"
#   //     KeyType = "HASH"
#   //   },
#   //   {
#   //     AttributeName = "account-region"
#   //     KeyType = "RANGE"
#   //   }
#   // ]
#   attribute = [
#     {
#       name = "Name"
#       type = "S"
#     },
#     {
#       name = "account-region"
#       type = "S"
#     }
#   ]
#   billing_mode = "PAY_PER_REQUEST"
#   point_in_time_recovery = {
#     PointInTimeRecoveryEnabled = True
#   }
#   // CF Property(SSESpecification) = {
#   //   KMSMasterKeyId = aws_kms_key.instance_scheduler_encryption_key.arn
#   //   SSEEnabled = True
#   //   SSEType = "KMS"
#   // }
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

# resource "aws_iam_policy" "ec2_permissions_b6_e87802" {
#   policy = {
#     Statement = [
#       {
#         Action = "ec2:ModifyInstanceAttribute"
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"
#       },
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:iam::*:role/*EC2SchedulerCross*"
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   name = "Ec2PermissionsB6E87802"
#   // CF Property(Roles) = [
#   //   aws_iam_role.scheduler_role.arn
#   // ]
# }

# resource "aws_iam_policy" "ec2_dynamo_db_policy" {
#   policy = {
#     Statement = [
#       {
#         Action = [
#           "ssm:GetParameter",
#           "ssm:GetParameters"
#         ]
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
#       },
#       {
#         Action = [
#           "logs:DescribeLogStreams",
#           "rds:DescribeDBClusters",
#           "rds:DescribeDBInstances",
#           "ec2:DescribeInstances",
#           "ec2:DescribeRegions",
#           "cloudwatch:PutMetricData",
#           "ssm:DescribeMaintenanceWindows",
#           "tag:GetResources"
#         ]
#         Effect = "Allow"
#         Resource = "*"
#       },
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:PutRetentionPolicy"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
#           aws_scheduler_schedule_group.scheduler_log_group.arn
#         ]
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   name = "EC2DynamoDBPolicy"
#   // CF Property(Roles) = [
#   //   aws_iam_role.scheduler_role.arn
#   // ]
# }

# resource "aws_iam_policy" "scheduler_policy" {
#   policy = {
#     Statement = [
#       {
#         Action = [
#           "rds:AddTagsToResource",
#           "rds:RemoveTagsFromResource",
#           "rds:DescribeDBSnapshots",
#           "rds:StartDBInstance",
#           "rds:StopDBInstance"
#         ]
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:rds:*:${data.aws_caller_identity.current.account_id}:db:*"
#       },
#       {
#         Action = [
#           "ec2:StartInstances",
#           "ec2:StopInstances",
#           "ec2:CreateTags",
#           "ec2:DeleteTags"
#         ]
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"
#       },
#       {
#         Action = "sns:Publish"
#         Effect = "Allow"
#         Resource = aws_sns_topic.instance_scheduler_sns_topic.id
#       },
#       {
#         Action = "lambda:InvokeFunction"
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.stack_name}-InstanceSchedulerMain"
#       },
#       {
#         Action = [
#           "kms:GenerateDataKey*",
#           "kms:Decrypt"
#         ]
#         Effect = "Allow"
#         Resource = aws_kms_key.instance_scheduler_encryption_key.arn
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   name = "SchedulerPolicy"
#   // CF Property(Roles) = [
#   //   aws_iam_role.scheduler_role.arn
#   // ]
# }

# resource "aws_iam_policy" "scheduler_rds_policy2_e7_c328_a" {
#   policy = {
#     Statement = [
#       {
#         Action = [
#           "rds:DeleteDBSnapshot",
#           "rds:DescribeDBSnapshots",
#           "rds:StopDBInstance"
#         ]
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:rds:*:${data.aws_caller_identity.current.account_id}:snapshot:*"
#       },
#       {
#         Action = [
#           "rds:AddTagsToResource",
#           "rds:RemoveTagsFromResource",
#           "rds:StartDBCluster",
#           "rds:StopDBCluster"
#         ]
#         Effect = "Allow"
#         Resource = "arn:${data.aws_partition.current.partition}:rds:*:${data.aws_caller_identity.current.account_id}:cluster:*"
#       }
#     ]
#     Version = "2012-10-17"
#   }
#   name = "SchedulerRDSPolicy2E7C328A"
#   // CF Property(Roles) = [
#   //   aws_iam_role.scheduler_role.arn
#   // ]
# }

