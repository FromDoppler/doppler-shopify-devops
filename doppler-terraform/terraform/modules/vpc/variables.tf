# vim: ts=4:sw=4:et:ft=hcl

variable "vpc_cidr" {
  description = "VPC CIDR"
}

variable "azs" {
  description = "Availability Zones list"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "Public subnets CIDR list"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "Private subnets CIDR list"
  type        = list(string)
  default     = []
}

# VPC specific parameters

variable "vpc_dns_hostnames" {
  description = "Boolean to enable/disable DNS Hostnames"
  default     = "true"
}

variable "vpc_dns_support" {
  description = "Boolean to enable/disable DNS support"
  default     = "true"
}

# VPC DHCP option parameters

variable "vpc_dhcp_opts_domain_name" {
  description = "VPC DHCP Domain name suffix"
  default     = "ec2.internal"
}

variable "vpc_dhcp_opts_domain_name_servers" {
  description = "VPC DHCP Domain name suffix"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}

variable "nat_gateway" {
  description = "Boolean to enable / disable creation of AWS NAT Gateways"
  default     = "true"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

