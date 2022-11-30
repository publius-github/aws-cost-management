resource "aws_kms_key" "instance_scheduler_encryption_key" {
  policy = {
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":root"])
        }
        Resource = "*"
        Sid      = "default"
      },
      {
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.scheduler_role.arn
        }
        Resource = "*"
        Sid      = "Allows use of key"
      },
      {
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:GenerateDataKey",
          "kms:TagResource",
          "kms:UntagResource"
        ]
        Effect = "Allow"
        Principal = {
          AWS = join("", ["arn:", data.aws_partition.current.partition, ":iam::", data.aws_caller_identity.current.account_id, ":root"])
        }
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  }
  description         = "Key for SNS"
  is_enabled          = True
  enable_key_rotation = True
}

resource "aws_kms_alias" "instance_scheduler_encryption_key_alias" {
  name          = join("", ["alias/", local.stack_name, "-instance-scheduler-encryption-key"])
  target_key_id = aws_kms_key.instance_scheduler_encryption_key.arn
}
