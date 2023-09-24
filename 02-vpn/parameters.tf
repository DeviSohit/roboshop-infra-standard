resource "aws_ssm_parameter" "vpn_sg_id" {
  name  = "/${var.project_name}/${var.env}/vpn_sg_id" #parameter name
  type  = "String"
  value = module.vpn_sg.security_group_id
}