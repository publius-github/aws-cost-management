resource "aws_iam_role" "scheduler_role" {
  assume_role_policy = {
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
    Version = "2012-10-17"
  }
  path = "/"
}

resource "aws_iam_policy" "scheduler_role_default_policy66_f774_b8" {
  policy = {
    Statement = [
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:ConditionCheckItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.state_table.arn,
          null
        ]
      },
      {
        Action = [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.config_table.arn,
          aws_dynamodb_table.maintenance_window_table.arn
        ]
      },
      {
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/Solutions/aws-instance-scheduler/UUID/*"
      }
    ]
    Version = "2012-10-17"
  }
  name = "SchedulerRoleDefaultPolicy66F774B8"
  // CF Property(Roles) = [
  //   aws_iam_role.scheduler_role.arn
  // ]
}

resource "aws_iam_role" "instanceschedulerlambda_lambda_function_service_role_ebf44_cd1" {
  assume_role_policy = {
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  }
  force_detach_policies = [
    {
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Effect   = "Allow"
            Resource = join("", ["arn:", data.aws_partition.current.partition, ":logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":log-group:/aws/lambda/*"])
          }
        ]
        Version = "2012-10-17"
      }
      PolicyName = "LambdaFunctionServiceRolePolicy"
    }
  ]
}

resource "aws_iam_policy" "ec2_permissions_b6_e87802" {
  policy = {
    Statement = [
      {
        Action   = "ec2:ModifyInstanceAttribute"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"
      },
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:iam::*:role/*EC2SchedulerCross*"
      }
    ]
    Version = "2012-10-17"
  }
  name = "Ec2PermissionsB6E87802"
  // CF Property(Roles) = [
  //   aws_iam_role.scheduler_role.arn
  // ]
}

resource "aws_iam_policy" "ec2_dynamo_db_policy" {
  policy = {
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
      },
      {
        Action = [
          "logs:DescribeLogStreams",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "cloudwatch:PutMetricData",
          "ssm:DescribeMaintenanceWindows",
          "tag:GetResources"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ]
        Effect = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
          aws_scheduler_schedule_group.scheduler_log_group.arn
        ]
      }
    ]
    Version = "2012-10-17"
  }
  name = "EC2DynamoDBPolicy"
  // CF Property(Roles) = [
  //   aws_iam_role.scheduler_role.arn
  // ]
}

resource "aws_iam_policy" "scheduler_policy" {
  policy = {
    Statement = [
      {
        Action = [
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource",
          "rds:DescribeDBSnapshots",
          "rds:StartDBInstance",
          "rds:StopDBInstance"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:rds:*:${data.aws_caller_identity.current.account_id}:db:*"
      },
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"
      },
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.instance_scheduler_sns_topic.id
      },
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.stack_name}-InstanceSchedulerMain"
      },
      {
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.instance_scheduler_encryption_key.arn
      }
    ]
    Version = "2012-10-17"
  }
  name = "SchedulerPolicy"
  // CF Property(Roles) = [
  //   aws_iam_role.scheduler_role.arn
  // ]
}

resource "aws_iam_policy" "scheduler_rds_policy2_e7_c328_a" {
  policy = {
    Statement = [
      {
        Action = [
          "rds:DeleteDBSnapshot",
          "rds:DescribeDBSnapshots",
          "rds:StopDBInstance"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:rds:*:${data.aws_caller_identity.current.account_id}:snapshot:*"
      },
      {
        Action = [
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource",
          "rds:StartDBCluster",
          "rds:StopDBCluster"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:rds:*:${data.aws_caller_identity.current.account_id}:cluster:*"
      }
    ]
    Version = "2012-10-17"
  }
  name = "SchedulerRDSPolicy2E7C328A"
  // CF Property(Roles) = [
  //   aws_iam_role.scheduler_role.arn
  // ]
}

