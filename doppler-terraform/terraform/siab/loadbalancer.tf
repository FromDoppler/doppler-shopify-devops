## Application load balancer for Shopify

## ALB for Shopify
resource "aws_alb" "alb" {
  name               = "${var.environment_code}-doppler-shopify-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  enable_deletion_protection = true

  tags = merge(
    local.common_tags,
    {
      "Name" = format(
        "%s-doppler-shopify-alb",
        var.environment_code
      )
    },
  )
}

## ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.doppler_ssl_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_tg.arn
  }
}
