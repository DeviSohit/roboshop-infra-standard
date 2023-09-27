module "mongodb_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops_ami.id
  instance_type = "t3.medium"
  vpc_security_group_ids = [data.aws_ssm_parameter.mongodb_sg_id.value]
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

#R53 record for mongodb
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
        name    = "mongodb"
        type    = "A"
        ttl     = 1
        records = [
            module.mongodb_instance.private_ip
        ]
    }
  ]
}