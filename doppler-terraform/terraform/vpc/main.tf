# vim: ts=4:sw=4:et:ft=hcl

## Bucket initialization
terraform {
  required_version = ">= 0.11.7"
  backend "s3" {
  }
}

## Provider selection
provider "aws" {
  region  = var.aws_region
}