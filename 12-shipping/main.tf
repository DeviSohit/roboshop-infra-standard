module "shipping" {
  source = "../../terraform-roboshop-app"
  project_name = var.project_name
  env = var.env
  common_tags = var.common_tags

  #target group
  #health_check = var.health_check #already mentioned in module i.e. is enough for user
  target_group_port = var.target_group_port
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  #launch template
  image_id = data.aws_ami.devops_ami.id
  security_group_id = data.aws_ssm_parameter.shipping_sg_id.value
  user_data = filebase64("${path.module}/shipping.sh")
  launch_template_tags = var.launch_template_tags

  #autoscaling
  vpc_zone_identifier = split(",",data.aws_ssm_parameter.private_subnet_ids.value) # in which subnet you want to provision web instances - private subnets
  tag = var.autoscaling_tags

  #autoscalingpolicy, I am good with optional parameters. No need to provide here, see in module

  #listener rule
  # Adding rule to private ALB listener i.e. if any request shipping.app.devidevops.online hits then request should be forward to user target group
  alb_listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  rule_priority = 40
  host_header = "shipping.app.devidevops.online"

}