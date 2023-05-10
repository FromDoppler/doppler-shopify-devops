# vim: ts=4:sw=4:et:ft=hcl

###############################################################################
# Obtain latest AMI

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:Role"
    values = [ var.lc_instance_role ]
  }
  filter {
    name   = "tag:Approved_for"
    values = ["*${var.environment}*"]
  }
}


###############################################################################
# Launch configuration

resource "aws_launch_configuration" "lc" {
  name_prefix          = var.lc_name_prefix
  image_id             = var.lc_ami_id != "" ? var.lc_ami_id : data.aws_ami.ami.id
  instance_type        = var.lc_instance_type
  key_name             = var.lc_key_name
  security_groups      = var.lc_security_groups
  user_data            = var.lc_user_data
  iam_instance_profile = var.lc_iam_instance_profile

  enable_monitoring = var.lc_monitoring
  ebs_optimized     = var.lc_ebs_optimized

  root_block_device {
    volume_type = var.lc_root_volume_type
    volume_size = var.lc_root_volume_size
    delete_on_termination = var.lc_root_block_device_delete
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = []
  }
}


###############################################################################
# Autoscaling group

resource "aws_autoscaling_group" "asg" {
  name                      = var.asg_name
  vpc_zone_identifier       = var.asg_subnet_ids
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  default_cooldown          = var.asg_default_cooldown
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_check_type
  force_delete              = var.asg_force_delete
  launch_configuration      = aws_launch_configuration.lc.name
  enabled_metrics           = var.asg_enabled_metrics
  target_group_arns         = var.asg_target_groups
  suspended_processes       = []

  tag {
    key                 = "Name"
    value               = var.asg_name_tag
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key    =  tag.key
      value   =  tag.value
      propagate_at_launch =  true
    }
  }
}

################################################################################
## Autoscaling group policies

## Scaling UP - CPU High
#resource "aws_autoscaling_policy" "cpu_high" {
#  name                   = "${var.asg_policy}-scalling-up"
#  autoscaling_group_name = aws_autoscaling_group.asg.name
#  adjustment_type        = "ChangeInCapacity"
#  policy_type            = "SimpleScaling"
#  scaling_adjustment     = "1"
#  cooldown               = "300"
#}
## Scaling DOWN - CPU Low
#resource "aws_autoscaling_policy" "cpu_low" {
#  name                   = "${var.asg_policy}-scalling-down"
#  autoscaling_group_name = aws_autoscaling_group.asg.name
#  adjustment_type        = "ChangeInCapacity"
#  policy_type            = "SimpleScaling"
#  scaling_adjustment     = "-1"
#  cooldown               = "300"
#}

################################################################################
## CloudWatch alarms

#resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
#  alarm_name          = "${var.asg_policy}-cpu-high-alarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = "2"
#  metric_name         = "CPUUtilization"
#  namespace           = "AWS/EC2"
#  period              = "60"
#  statistic           = "Average"
#  threshold           = "65"
#  actions_enabled     = true
#  alarm_actions       = ["${aws_autoscaling_policy.cpu_high.arn}"]
#  dimensions = {
#    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
#  }
#}
#resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
#  alarm_name          = "${var.asg_policy}-cpu-low-alarm"
#  comparison_operator = "LessThanOrEqualToThreshold"
#  evaluation_periods  = "2"
#  metric_name         = "CPUUtilization"
#  namespace           = "AWS/EC2"
#  period              = "60"
#  statistic           = "Average"
#  threshold           = "20"
#  actions_enabled     = true
#  alarm_actions       = ["${aws_autoscaling_policy.cpu_low.arn}"]
#  dimensions = {
#    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
#  }
#}