resource "aws_config_config_rule" "sg_attached" {
  name = "ec2-security-group-attached-to-eni"

  source {
    owner             = "AWS"
    source_identifier = "EC2_SECURITY_GROUP_ATTACHED_TO_ENI"
  }
}

resource "aws_config_remediation_configuration" "sg_attached" {
  config_rule_name = aws_config_config_rule.sg_attached.name
  resource_type    = "AWS::EC2::SecurityGroup"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-DeleteUnusedSecurityGroup"
  target_version   = "1"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.aws_config_sg_attached_remediation_role.arn
  }

  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }
}
