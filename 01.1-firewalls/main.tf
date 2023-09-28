module "vpn_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    sg_name = "roboshop-vpn"
    sg_description = "Allowing all ports from my home IP"
    #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
    vpc_id = data.aws_vpc.default.id
    common_tags = merge(
        var.common_tags,
        {
            Component = "VPN",
            Name = "roboshop-VPN"
        }
    )
}

module "mongodb_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    sg_name = "mongodb"
    sg_description = "Allowing traffic"
    #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value #vpc id of roboshop
    common_tags = merge(
        var.common_tags,
        {
            Component = "MongoDB",
            Name = "MongoDB"
        }
    )
}

module "catalogue_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    sg_name = "catalogue"
    sg_description = "Allowing traffic"
    #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value #vpc id of roboshop
    common_tags = merge(
        var.common_tags,
        {
            Component = "Catalogue",
            Name = "Catalogue"
        }
    )
}

module "web_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    sg_name = "web"
    sg_description = "Allowing traffic"
    #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value #vpc id of roboshop
    common_tags = merge(
        var.common_tags,
        {
            Component = "Web"
        }
    )
}

module "app_alb_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    sg_name = "App-ALB"
    sg_description = "Allowing traffic"
    #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value #vpc id of roboshop
    common_tags = merge(
        var.common_tags,
        {
            Component = "APP"
            Name = "App-ALB"
        }
    )
}

module "web_alb_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    sg_name = "Web-ALB"
    sg_description = "Allowing traffic"
    #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value #vpc id of roboshop
    common_tags = merge(
        var.common_tags,
        {
            Component = "WEB"
            Name = "Web-ALB"
        }
    )
}

# VPN is Allowing all ports from my ip
resource "aws_security_group_rule" "vpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] #allow all ports from my IP
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.vpn_sg.security_group_id
}

# MongoDB is allowing connections/traffic from all catalogue instances on 27017 port
resource "aws_security_group_rule" "mongodb_catalogue" {
  type              = "ingress"
  description = "Allowing port number 27017 from catalogue"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = module.catalogue_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.mongodb_sg.security_group_id
}

# MongoDb is allowing traffic from VPN on port no 22 for trouble shooting
resource "aws_security_group_rule" "mongodb_vpn" {
  type              = "ingress"
  description = "Allowing port number 22 from VPN"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.mongodb_sg.security_group_id
}

# Catalogue is allowing traffic from VPN on port no 22 for trouble shooting
resource "aws_security_group_rule" "catalogue_vpn" {
  type              = "ingress"
  description = "Allowing port number 22 from VPN"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.catalogue_sg.security_group_id
}

# Catalogue should allow traffic from private LB on port no 8080
resource "aws_security_group_rule" "catalogue_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.catalogue_sg.security_group_id
}

# Private LB should allow traffic from vpn on port no 80. all LB run on port no 80
resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  description = "Allowing port number 80 from vpn"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.app_alb_sg.security_group_id
}

# Private LB should allow traffic from web on port no 80
resource "aws_security_group_rule" "app_alb_web" {
  type              = "ingress"
  description = "Allowing port number 80 from web"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.app_alb_sg.security_group_id
}

# Web should allow traffic from vpn on port no 80
resource "aws_security_group_rule" "web_vpn" {
  type              = "ingress"
  description = "Allowing port number 80 from vpn"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_sg.security_group_id
}

# Web should allow traffic from vpn on port no 22
resource "aws_security_group_rule" "web_vpn_ssh" {
  type              = "ingress"
  description = "Allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_sg.security_group_id
}

# Web should allow traffic from public LB on port no 80
resource "aws_security_group_rule" "web_web_alb" {
  type              = "ingress"
  description = "Allowing port number 80 from public LB"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_sg.security_group_id
}

# Public LB should allow traffic from internet on port no 80
resource "aws_security_group_rule" "web_alb_internet" {
  type              = "ingress"
  description = "Allowing port number 80 from internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] #internet ip
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_alb_sg.security_group_id
}

# Public LB should allow traffic from internet on port no 443
resource "aws_security_group_rule" "web_alb_internet_https" {
  type              = "ingress"
  description = "Allowing port number 443 from internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] #internet ip
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_alb_sg.security_group_id
}