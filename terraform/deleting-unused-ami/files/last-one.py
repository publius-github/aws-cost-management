

def lambda_handler(event, context):
  amis_in_use = []
  total_amis_deleted = 0
  total_snapshots_deleted = 0

  try:
    regions = event['regions']
    max_ami_age_to_prevent_deletion = event['max_ami_age_to_prevent_deletion']

    filters = makeAmiFilters(event['ami_tags'])

    for region in regions:
      amis_in_use = list(set(imagesInASGs(region) + imagesUsedInEC2s(region)))
      ec2 = boto3.client('ec2', region_name = region)
      amis = ec2.describe_images(
        Owners = ['self'],
        Filters = filters
      ).get('Images')
      for ami in amis:
        now = datetime.now()
        ami_id = ami['ImageId']
        img_creation_datetime = datetime.strptime(ami['CreationDate'], '%Y-%m-%dT%H:%M:%S.%fZ')
        days_since_creation = (now - img_creation_datetime).days

        if ami_id not in amis_in_use and days_since_creation > max_ami_age_to_prevent_deletion:
          ec2.deregister_image(ImageId = ami_id)
          total_amis_deleted += 1

          for ebs in ami['BlockDeviceMappings']:
            if 'Ebs' in ebs:
              snapshot_id = ebs['Ebs']['SnapshotId']              
              ec2.delete_snapshot(SnapshotId=snapshot_id)
              total_snapshots_deleted += 1

    print(f"Deleted {total_amis_deleted} AMIs and {total_snapshots_deleted} EBS snapshots")

  except Exception as e:
    send_alert(f"AMI cleaner failure", e)

def imagesInASGs(region):
  amis = []
  autoscaling = boto3.client('autoscaling', region_name=region)
  print(f'Checking autoscaling groups in region {region}...')
  paginator = autoscaling.get_paginator('describe_auto_scaling_groups')

  page_iterator = paginator.paginate(
    PaginationConfig = {'PageSize': 10}
  )  
  filtered_asgs = page_iterator.search(f"AutoScalingGroups[*].[Instances[?LifecycleState == 'InService'].[InstanceId, LaunchTemplate.LaunchTemplateId,LaunchTemplate.Version]]")

  for key_data in filtered_asgs:
    matches = re.findall(r"'(.+?)'",str(key_data))
    instance_id = matches[0]
    template = matches[1]
    version = matches[2]
    print(f"Template found: {template} version {version}")

    if (template == ""):
      send_alert(f"AMI cleaner failure", f"Failed to find launch template that was used for instance {instance_id}")
      return

    ec2 = boto3.client('ec2', region_name = region)
    launch_template_versions = ec2.describe_launch_template_versions(
      LaunchTemplateId=template, 
      Versions=[version]
    );  
    used_ami_id = launch_template_versions["LaunchTemplateVersions"][0]["LaunchTemplateData"]["ImageId"]
    if not used_ami_id:
      send_alert(f"AMI cleaner failure", f"Failed to find AMI for launch template {template} version {version}")
      return    
    amis.append(used_ami_id)
  return amis

def imagesUsedInEC2s(region):
  print(f'Checking instances that are not in ASGs in region {region}...')
  amis = []
  ec2_resource = boto3.resource('ec2', region_name = region)
  instances = ec2_resource.instances.filter(
    Filters=
    [
      {
        'Name': 'instance-state-name',
        'Values': [ 'running' ]
      }
    ])
  for instance in list(instances):
      amis.append(instance.image_id)

  return amis

def makeAmiFilters(ami_tags):
  filters = [
    {
      'Name': 'state',
      'Values': ['available']
    }
  ]
  for tag in ami_tags:
    filters.append({'Name': f'tag:{key}', 'Values':[f'{value}'] })
  return filters

def send_alert(subject, message):
  sns.publish(
    TargetArn=os.environ['sns_topic_arn'], 
    Subject=subject, 
    Message=message)