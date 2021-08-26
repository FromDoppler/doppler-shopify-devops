# vim: ts=4:sw=4:et:ft=hcl

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support
  instance_tenancy     = "default"

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "%s-vpc",
        var.tags["managed_by"],
      )
    },
  )
}

resource "aws_internet_gateway" "igw" {
  depends_on = [aws_vpc.vpc]

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "public-igw-%s",
        var.tags["managed_by"],
      )
    },
  )
}

###############################################################################
# << DHCP Options

resource "aws_vpc_dhcp_options" "dhcp_opts" {
  depends_on = [aws_vpc.vpc]

  domain_name         = var.vpc_dhcp_opts_domain_name
  domain_name_servers = var.vpc_dhcp_opts_domain_name_servers

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "%s-dhcp-options-set",
        var.tags["managed_by"],
      )
    },
  )
}

resource "aws_vpc_dhcp_options_association" "dhcp_assoc" {
  depends_on = [aws_vpc.vpc]

  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_opts.id
}

###############################################################################
# << Route Tables

## Public route table

resource "aws_route_table" "public" {
  depends_on = [aws_vpc.vpc]

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "public-rt-%s",
        var.tags["managed_by"],
      )
    },
  )
}

## Private route tables

resource "aws_route_table" "private" {
  depends_on = [aws_vpc.vpc]

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "private-rt-%s",
        var.tags["managed_by"],
      )
    },
  )
}

## Public default route 

resource "aws_route" "igw" {
  depends_on = [aws_route_table.public]

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

###############################################################################
# << Subnets

# Get current region (defined by provider configuration)
data "aws_region" "current" {
}

## Public subnets

resource "aws_subnet" "public" {
  count      = length(var.public_subnets)
  depends_on = [aws_route_table.public]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = format(
    "%s%s",
    replace(data.aws_region.current.name, "/[0-9]$/", ""),
    element(var.azs, count.index),
  )

  map_public_ip_on_launch = "true"

  tags = merge(
    var.tags,
    {
      "Name" = format("subnet-public-%s", element(var.azs, count.index))
    },
  )
}

## Private subnets

resource "aws_subnet" "private" {
  count      = length(var.private_subnets)
  depends_on = [aws_route_table.private]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = format(
    "%s%s",
    replace(data.aws_region.current.name, "/[0-9]$/", ""),
    element(var.azs, count.index),
  )

  map_public_ip_on_launch = "false"

  tags = merge(
    var.tags,
    {
      "Name" = format("subnet-private-%s", element(var.azs, count.index))
    },
  )
}

###############################################################################     
# << NAT gateways       

resource "aws_eip" "nat" {
  depends_on = [aws_route_table.public]
  vpc        = "true"
}

resource "aws_nat_gateway" "nat" {
  depends_on = [aws_eip.nat]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.0.id

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "private-gw-%s",
        var.tags["managed_by"],
      )
    },
  )
}

resource "aws_route" "private_nat" {
  depends_on = [aws_nat_gateway.nat]

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

###############################################################################
# << VPC endpoints

## S3

# Obtain vpc endpoint service name
data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
}

resource "aws_vpc_endpoint_route_table_association" "s3_public" {
  depends_on = [aws_route_table.public]

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.public.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  depends_on = [aws_route_table.private]

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private.id
}

###############################################################################
# << Route Tables Association

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
