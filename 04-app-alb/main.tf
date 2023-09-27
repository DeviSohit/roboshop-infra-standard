# Private ALB-application load balancer
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-${var.common_tags.Component}"
  internal           = true # this is private LB. internal means private = true
  load_balancer_type = "application" # this is 
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",",data.aws_ssm_parameter.private_subnet_ids.value) #this will give list of private subnets.atleast in 2 subnets we have to provision

  #enable_deletion_protection = true #if you enable it you can't delete accidentally

  tags = var.common_tags
}

# creating HTTP:80 listener and attach to private LB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  # This will add one listener on port no 80 and one default rule
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is the fixed response from APP ALB"
      status_code  = "200"
    }
  }
}

#creating R53 record for private ALB dns name
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = "devidevops.online"

  records = [
    {
      name    = "*.app"
      type    = "A"
      alias   = {
        name    = aws_lb.app_alb.dns_name # App ALB dns name
        zone_id = aws_lb.app_alb.zone_id # App ALB dns name
      }
    }
  ]
}