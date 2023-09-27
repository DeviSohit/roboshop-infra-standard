# create public ALB
resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-${var.common_tags.Component}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.web_alb_sg_id.value]
  subnets            = split(",",data.aws_ssm_parameter.public_subnet_ids.value)

  tags = var.common_tags
}

#this is expose to the public, so HTTPS:443 port
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"

  # This will add one listener on port no 443 and one default rule
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is the fixed response from WEB ALB"
      status_code  = "200"
    }
  }
}