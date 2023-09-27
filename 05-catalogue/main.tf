# create catalogue instances target group to add all catalogue instances into this
resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project_name}-${var.common_tags.Component}"
  port     = 8080 # all catalogue components ryn on 8080 port
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    enabled = true
    healthy_threshold = 2 # consider as healthy if 2 health checks are success
    interval = 15 # every 15 sec we will check health of component(giving response)
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 5 # within 5 sec if u r not getting response consider it as fail
    unhealthy_threshold = 3
  }
}

#create launch template for creating catalogue instance by autoscaling
resource "aws_launch_template" "catalogue" {
  name = "${var.project_name}-${var.common_tags.Component}"

  image_id = data.aws_ami.devops_ami.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Catalogue"
    }
  }

  user_data = filebase64("${path.module}/catalogue.sh")
}

# create catalogue autoscaling group and add catalogue target group
resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project_name}-${var.common_tags.Component}"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  target_group_arns = [aws_lb_target_group.catalogue.arn] #adding catalogue instances into catalogue target group
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  # provisioning in 2 AZ's 1a and 1b
  vpc_zone_identifier       = split(",",data.aws_ssm_parameter.private_subnet_ids.value)

  tag {
    key                 = "Name"
    value               = "Catalogue"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

# Adding autoscaling policy to catalo0gue autoscaling group : if each catalogue reaches more than 50% of CPU then create more instances
resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  name                   = "cpu"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

# Adding rule to the private LB i.e. request should be forward to catalogue target group from ALB based on host_header condition
resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value #rule attaching to private ALB
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.app.devidevops.online"]
    }
  }
}


