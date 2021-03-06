# vim: ts=4:sw=4:et:ft=hcl

variable "environment" {
  description = "Environment"
}

variable "ami_owner_alias" {
  description = "AMI owner. Defaults to amazon"
  default     = "amazon"
}

variable "ami_name" {
  description = "AMI name. Defaults to amazon"
  default     = "amzn-ami-hvm-*"
}

variable "ami_architecture" {
  default = "x86_64"
}

variable "ami_hipervisor" {
  default = "xen"
}

# Launch Config

variable "lc_instance_role" {
  description = "Launch Configuration instance role"
  default = "base"
}

variable "lc_name_prefix" {
  description = "Launch Configuration name prefix"
}

variable "lc_ami_id" {
  description = "AMI ID"
  default     = ""
}

variable "lc_instance_type" {
  description = "EC2 Instance type for launch configuration"
}

variable "lc_key_name" {
  description = "SSH Key name for launch configuration"
}

variable "lc_security_groups" {
  description = ""
  type        = list(string)
}

variable "lc_user_data" {
  description = "User Data script for launch configuration"
  default = ""
}

variable "lc_monitoring" {
  description = "Enable detailed monitoring"
  default     = "true"
}

variable "lc_ebs_optimized" {
  description = "EBS optiomized EC2 instance"
  default     = "true"
}

variable "lc_iam_instance_profile" {
  description = "IAM instance profile to attach"
  default = ""
}

variable "lc_root_volume_size" {
  default = "20"
}
variable "lc_root_volume_type" {
  default = "gp2"
}
variable "lc_root_block_device_delete" {
  default = true
}
variable "lc_encrypted" {
  default = false
}
variable "lc_iops" {
  default = "0"
}
variable "lc_no_device" {
  default = false
}

# Autoscaling group

variable "asg_name" {
  description = "Autoscaling group name"
}

variable "asg_subnet_ids" {
    description = "List of subnets for the autoscaling group"
    type        = list
}

variable "asg_desired_capacity" {
    description = "Desired capacity for the autoscaling group"
    default     = 0
}

variable "asg_min_size" {
    description = "Minimum capacity for the autoscaling group"
    default     = 0
}

variable "asg_max_size" {
    description = "Maximum capacity for the autoscaling group"
    default     = 0
}

variable "asg_health_check_grace_period" {
    description = ""
    default     = "300"
}

variable "asg_default_cooldown" {
    description = "Time in seconds after a scaling activity completes before another one begins"
    default = "300"
}

variable "asg_check_type" {
    description = "Check to define instance type"
    default     = "EC2"
}

variable "asg_force_delete" {
    description = "Force deletion of resource. Might leave resources dangling"
    default     = "false"
}

variable "asg_enabled_metrics" {
    description = "A list of metrics to collect"
    type        = list
    default     = []
}

variable "asg_target_groups" {
    description = "Target groups"
    default     = []
}

variable "tags_asg" {
    type    = list
    default = []
}

variable "asg_name_tag" {
    description   = "Name for autoscaling group"
    default = ""
}
variable "instance_name_tag" {
    description   = "Name for autoscaling group instances"
    default = ""
}
variable "instance_role_tag" {
    description   = "Role for autoscaling group instances"
    default = ""
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}

variable "application" {
  description = "Application insight / servicedesk"
  type  = string
  default = ""
}

variable "asg_policy" {
  description = "ASG Policy NAme"
  type = string
  default = ""
}