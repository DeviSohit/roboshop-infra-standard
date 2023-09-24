resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.env}/vpc_id" #parameter name
  type  = "String"
  value = module.vpc.vpc_id #module should have output declaration like vpc_id
  #already aws_vpc.main.id stored in output vpc_id in module. so directly taking output name here as vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.env}/public_subnet_ids" #parameter name
  type  = "StringList"
  value = join(",",module.vpc.public_subnet_ids) #module should have output declaration like vpc_id
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.env}/private_subnet_ids" #parameter name
  type  = "StringList"
  value = join(",",module.vpc.private_subnet_ids) #module should have output declaration
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project_name}/${var.env}/database_subnet_ids" #parameter name
  type  = "StringList"
  value = join(",",module.vpc.database_subnet_ids) #module should have output declaration 
}