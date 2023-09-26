# module "mongodb_sg" {
#     source = "../../terraform-aws-securitygroup"
#     project_name = var.project_name
#     sg_name = "mongodb"
#     sg_description = "Allowing traffic"
#     #sg_ingress_rules = var.sg_ingress_rules #create ingress rules seperately resource rules
#     vpc_id = data.aws_ssm_parameter.vpc_id.value #vpc id of roboshop
#     common_tags = var.common_tags
# }

# # Adding rule to mongodb SG, that is allowing traffic from vpn instance
# resource "aws_security_group_rule" "mongodb_vpn" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = data.aws_ssm_parameter.vpn_sg_id.value
#   #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] 
#   #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
#   security_group_id = module.mongodb_sg.security_group_id
# }

module "mongodb_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops_ami.id
  instance_type = "t3.medium"
  vpc_security_group_ids = [module.mongodb_sg.security_group_id]
  # MongoDB instance should be provisioned in Roboshop database subnet
  subnet_id = local.db_subnet_id  # splitting the value of ssm parameter of database subnet of roboshop in us-east-1a, 0th means first subnet id
  user_data = file("mongodb.sh")
  tags = merge(
    {
        Name = "MongoDB"
    },
    var.common_tags
  )
}