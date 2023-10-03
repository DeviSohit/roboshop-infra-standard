module "mysql_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops_ami.id
  instance_type = "t3.medium"
  vpc_security_group_ids = [data.aws_ssm_parameter.mysql_sg_id.value]
  # Redis instance should be provisioned in Roboshop database subnet
  subnet_id = local.db_subnet_id  # splitting the value of ssm parameter of database subnet of roboshop in us-east-1a, 0th means first subnet id
  user_data = file("mysql.sh")
  tags = merge(
    {
        Name = "Mysql"
    },
    var.common_tags
  )
}

#R53 record for redis
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
        name    = "mysql"
        type    = "A"
        ttl     = 1
        records = [
            module.mysql_instance.private_ip
        ]
    }
  ]
}