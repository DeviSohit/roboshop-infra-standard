data "aws_vpc" "default" {
  default = true
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project_name}/${var.env}/vpn_sg_id" #referring from 01.1-firewalls/parameters.tf
}

data "aws_ami" "devops_ami" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]

  filter {
    name   = "name"
    values = ["Centos-8-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}