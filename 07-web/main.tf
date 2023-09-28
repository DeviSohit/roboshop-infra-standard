module "web" {
  source = "../../terraform-roboshop-app"
  project_name = var.project_name
  env = var.env
  common_tags = var.common_tags

  #target group
  health_check = var.health_check
  target_group_port = var.target_group_port
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  #launch template
  image_id = data.aws_ami.devops_ami.id
  security_group_id = data.aws_ssm_parameter.web_sg_id.value
  user_data = filebase64("${path.module}/web.sh")
  launch_template_tags = var.launch_template_tags

  #autoscaling
  vpc_zone_identifier = split(",",data.aws_ssm_parameter.private_subnet_ids.value) # in which subnet you want to provision web instances - private subnets
  tag = var.autoscaling_tags

  #autoscalingpolicy, I am good with optional parameters. No need to provide here, see in module

  #listener rule
  # Adding rule to public ALB listener i.e. if any request devidevops.online hits then request should be forward to web target group
  alb_listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
  rule_priority = 10
  host_header = "devidevops.online"

}