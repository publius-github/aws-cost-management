resource "aws_dynamodb_table" "state_table" {
  // CF Property(KeySchema) = [
  //   {
  //     AttributeName = "service"
  //     KeyType = "HASH"
  //   },
  //   {
  //     AttributeName = "account-region"
  //     KeyType = "RANGE"
  //   }
  // ]
  attribute = [
    {
      name = "service"
      type = "S"
    },
    {
      name = "account-region"
      type = "S"
    }
  ]
  billing_mode = "PAY_PER_REQUEST"
  point_in_time_recovery = {
    PointInTimeRecoveryEnabled = True
  }
  // CF Property(SSESpecification) = {
  //   KMSMasterKeyId = aws_kms_key.instance_scheduler_encryption_key.arn
  //   SSEEnabled = True
  //   SSEType = "KMS"
  // }
}

resource "aws_dynamodb_table" "config_table" {
  // CF Property(KeySchema) = [
  //   {
  //     AttributeName = "type"
  //     KeyType = "HASH"
  //   },
  //   {
  //     AttributeName = "name"
  //     KeyType = "RANGE"
  //   }
  // ]
  attribute = [
    {
      name = "type"
      type = "S"
    },
    {
      name = "name"
      type = "S"
    }
  ]
  billing_mode = "PAY_PER_REQUEST"
  point_in_time_recovery = {
    PointInTimeRecoveryEnabled = True
  }
  // CF Property(SSESpecification) = {
  //   KMSMasterKeyId = aws_kms_key.instance_scheduler_encryption_key.arn
  //   SSEEnabled = True
  //   SSEType = "KMS"
  // }
}

resource "aws_dynamodb_table" "maintenance_window_table" {
  // CF Property(KeySchema) = [
  //   {
  //     AttributeName = "Name"
  //     KeyType = "HASH"
  //   },
  //   {
  //     AttributeName = "account-region"
  //     KeyType = "RANGE"
  //   }
  // ]
  attribute = [
    {
      name = "Name"
      type = "S"
    },
    {
      name = "account-region"
      type = "S"
    }
  ]
  billing_mode = "PAY_PER_REQUEST"
  point_in_time_recovery = {
    PointInTimeRecoveryEnabled = True
  }
  // CF Property(SSESpecification) = {
  //   KMSMasterKeyId = aws_kms_key.instance_scheduler_encryption_key.arn
  //   SSEEnabled = True
  //   SSEType = "KMS"
  // }
}
