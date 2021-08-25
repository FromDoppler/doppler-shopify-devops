## Main Doppler infrastructure template

## Policy for S3 bucket
data "aws_caller_identity" "current" {
}

data "aws_elb_service_account" "main" {
}

## Bucket initialization
terraform {
  required_version = ">= 0.11.7"
  backend "s3" {
  }
  required_providers {
    mysql = {
      source  = "winebarrel/mysql"
      version = "~> 1.10.2"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

## Retrieve VPC data
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tf_bucket
    key    = "${var.aws_region}/operations/vpc/terraform.tfstate"
    region = var.aws_region
  }
}

# Retrieve IAM data
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.tf_bucket
    key    = "${var.aws_region}/operations/iam/terraform.tfstate"
    region = var.aws_region
  }
}