## SecurityGroups for Doppler Shopify

## EC2 SecGrp for Doppler Shopify
resource "aws_security_group" "doppler_security_group" {
  name = "${var.environment_code}-sg-doppler-shopify"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Allow incomming http and https traffic"
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.admin_access_cidr
  }
  egress {
    from_port= 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = format(
        "sg-doppler-shopify-%s",
        var.environment_code,
      )
    },
  )

}

## EC2 SecGrp for ALB
resource "aws_security_group" "alb_security_group" {
  name = "${var.environment_code}-alb"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Allow incomming http and https traffic"
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = format(
        "sg-doppler-shopify-%s",
        var.environment_code,
      )
    },
  )
}

resource "aws_security_group_rule" "alb_security_group_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  source_security_group_id = aws_security_group.doppler_security_group.id
  security_group_id = aws_security_group.alb_security_group.id
}
