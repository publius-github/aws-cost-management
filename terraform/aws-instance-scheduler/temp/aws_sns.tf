resource "aws_sns_topic" "instance_scheduler_sns_topic" {
  kms_master_key_id = aws_kms_key.instance_scheduler_encryption_key.arn
}
