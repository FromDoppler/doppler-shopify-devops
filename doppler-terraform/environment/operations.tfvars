# TF statment
tf_bucket                       = "doppler-tf-states"

# VPC
aws_region                      = "us-east-2"
environment                     = "operations"
account                         = "288672893446"
vpc_cidr                        = "10.0.0.0/16"
azs                             = [ "2a", "2b", "2c" ]
public_subnets                  = [ "10.0.128.0/24", "10.0.129.0/24", "10.0.130.0/24" ]
private_subnets                 = [ "10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24" ]
access_cidr                     = [ "0.0.0.0/0" ]
ssh_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDezxGlTIF1sQoGaAfPw2XAjFjTyh/tDriJTAte4be/Xlbw1NIJQ1iwQhAykLdswMgYgNJ6PXQxe2z8TcuYPzgzQeMiqFoL0/W0G16uwUul0EYkxXK2iRcuzA7X8WVV05eGm8h8AZhd5m+8yZBTScg9fZ+69VIjy9GnY67nYgVm4g84QYTgW1qtRRKjYsXoMxNjxzAb5sIU44jnPmRsRhVLUcI0Ps95diKa2rd0HJAZxQu+jil9rBfS3W0wIdhOznexMBoqHTjxyl4weaTKPXb1JY4HS31EBE4u6Ll+pTeVzj5k0oxz267tCqRBqM5ITLjieJEOUMizuhFBneO/f4UEBW0VzzR4yG1yV7Ic6fbdoREMML2TJr0lMbC56DEXmZy1afbj3W/iz4TsZdPcT2NUOebhpPKcDrf+4H28m2xrIFSVmf5azA3XBCQqwTRPSYHRZ/2tnmtxLj2vpeT9vWpb0YIP4/C6nhjiXGw3f7/NOPMvc2LEtOJzWhUBUNZ28u8= us-east-1"
region_name                     = "virginia"
environment_code                = "ops"
ops_vpc_id                      = ""

## DNS

## ACM Certificate Manater
