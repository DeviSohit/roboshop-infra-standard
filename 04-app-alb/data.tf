data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.env}/vpc_id" #referring from 01-vpc/parameters.tf
}

data "aws_ssm_parameter" "app_alb_sg_id" {
  name = "/${var.project_name}/${var.env}/app_alb_sg_id" #referring from 01-vpc/parameters.tf
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${var.env}/private_subnet_ids" #referring from 01-vpc/parameters.tf
}