module "rabbitmq_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.rabbitmq_sg_id.value]
  # Redis instance should be provisioned in Roboshop database subnet
  subnet_id = local.db_subnet_id  # splitting the value of ssm parameter of database subnet of roboshop in us-east-1a, 0th means first subnet id
  user_data = file("rabbitmq.sh")
  tags = merge(
    {
        Name = "Rabbitmq"
    },
    var.common_tags
  )
}

#R53 record for rabbitmq
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
        name    = "rabbitmq"
        type    = "A"
        ttl     = 1
        records = [
            module.rabbitmq_instance.private_ip
        ]
    }
  ]
}