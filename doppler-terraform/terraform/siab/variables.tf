# vim: ts=4:sw=4:et:ft=hcl

# Terraform states
variable "tf_bucket" {}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "environment_code" {
  type = string
}

variable "role" {
  type = string
}

variable "iam_role" {
  type = string
}

variable "az" {
  type = list(string)
}

variable "private_subnets_cidr" {
  type = list(string)
}

variable "asg_enabled_metrics" {
  type = list(string)
}

variable "isntance_type" {
  type = string
}

variable "asg_desired_capacity" {
  type = string
}

variable "asg_min_size" {
  type = string
}

variable "asg_max_size" {
  type = string
}

variable "asg_check_type" {
  type = string
}

variable "doppler_ssl_arn" {
  type = string
}