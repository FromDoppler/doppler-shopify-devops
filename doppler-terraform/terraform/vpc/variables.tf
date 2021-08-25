# vim: ts=4:sw=4:et:ft=hcl

# Terraform states
variable "tf_bucket" {}

variable "vpc_cidr" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "azs" {
  description = "Array de las subnets de la VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "Array de las subnets publicas de la VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "Array de las subnets privadas de la VPC"
  type        = list(string)
}

variable "environment_code" {
  type        = string
  description = "ops para virginia"
}

variable "region_name" {
  type        = string
  description = "virginia, london, frankfurt"
}

variable "ops_vpc_id" {
  type = string
}

variable "account" {
  type = string
}

variable "ssh_public_key" {
  type = string
}