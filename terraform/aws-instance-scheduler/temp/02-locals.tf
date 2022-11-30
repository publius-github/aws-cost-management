locals {
  mappings = {
    mappings = {
      TrueFalse = {
        Yes = "True"
        No  = "False"
      }
      EnabledDisabled = {
        Yes = "ENABLED"
        No  = "DISABLED"
      }
      Services = {
        EC2  = "ec2"
        RDS  = "rds"
        Both = "ec2,rds"
      }
      Timeouts = {
        1  = "cron(0/1 * * * ? *)"
        2  = "cron(0/2 * * * ? *)"
        5  = "cron(0/5 * * * ? *)"
        10 = "cron(0/10 * * * ? *)"
        15 = "cron(0/15 * * * ? *)"
        30 = "cron(0/30 * * * ? *)"
        60 = "cron(0 0/1 * * ? *)"
      }
      Settings = {
        MetricsUrl        = "https://metrics.awssolutionsbuilder.com/generic"
        MetricsSolutionId = "S00030"
      }
    }
    Send = {
      AnonymousUsage = {
        Data = "Yes"
      }
      ParameterKey = {
        UniqueId = "/Solutions/aws-instance-scheduler/UUID/"
      }
    }
  }
  stack_name = "aws-instance-scheduler"
  stack_id   = uuidv5("dns", "aws-instance-scheduler")
}

