# vim: ts=4:sw=4:et:ft=hcl

## VPC for regions
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  region               = var.aws_region
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets

  tags = local.common_tags
}

## Main Key
module "main_key" {
  source = "../modules/key_pair"

  key_name   = "prd-${var.aws_region}"
  public_key = var.ssh_public_key
}