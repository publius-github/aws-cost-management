resource "aws_cloudformation_stack" "aws_instance_scheduler" {
  name         = "aws-instance-scheduler"
  capabilities = ["CAPABILITY_IAM"]
  parameters = {
    TagName             = "schedule"
    ScheduledServices   = "EC2"
    ScheduleRdsClusters = "No"
    CreateRdsSnapshot   = "Yes"
    SchedulingActive    = "Yes"
    Regions             = "us-east-1"

    DefaultTimezone   = "UTC"
    CrossAccountRoles = ""

    ScheduleLambdaAccount = "Yes"


    SchedulerFrequency   = "5"
    UseCloudWatchMetrics = "No"

    MemorySize                  = "128"
    Trace                       = "No"
    EnableSSMMaintenanceWindows = "No"
    LogRetentionDays            = "30"
    StartedTags                 = "tagname=tagvalue"
    StoppedTags                 = "tagname=tagvalue"
  }

  template_body = file("aws-instance-scheduler.template")
}
