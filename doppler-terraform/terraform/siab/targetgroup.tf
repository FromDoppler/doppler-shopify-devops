## Applicatino load balancer for Shopify

## TG for http
resource "aws_lb_target_group" "http_tg" {
  name     = "${var.environment_code}-doppler-shopify-http"
  port          = 80
  protocol      = "HTTP"
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check {
    protocol    = "HTTP"
    interval    = 15
    path = "/"
    timeout = 5
    matcher = "200,301"
    healthy_threshold = 5
  }
}

## TG for https
resource "aws_lb_target_group" "https_tg" {
  name     = "${var.environment_code}-doppler-shopify-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check {
    protocol    = "HTTPS"
    interval    = 15
    path = "/"
    timeout = 5
    matcher = "200,301"
    healthy_threshold = 5
  }
}