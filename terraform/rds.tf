resource "aws_db_instance" "tf_rds_instance" {
  identifier             = "nodejs-rds"
  allocated_storage      = 10
  db_name                = var.dbname
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [module.tf_rds_sg_module.security_group_id] #[aws_security_group.tf_rds_sg.id]
}

#resource "aws_security_group" "tf_rds_sg" {
#  name        = "rds-security-group"
#  description = "Security group for RDS instance"
#  vpc_id      = var.vpc_id
#
#  ingress {
#    from_port       = 3306
#    to_port         = 3306
#    protocol        = "tcp"
#    cidr_blocks     = ["122.170.192.47/32"]
#    security_groups = [aws_security_group.tf_ec2_sg.id]
#  }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
## Creating security group from module
module "tf_rds_sg_module" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"
  name        = "rds-instance-sg"
  description = "Security group from module for RDS instance"
  vpc_id      = var.vpc_id
  ingress_with_cidr_blocks = [
    {
      rule        = "mysql-tcp"
      cidr_blocks = "122.170.198.180/32"
    },
  ]
  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.tf_sg_module.security_group_id
    },
  ]
  egress_rules = ["all-all"]
}

locals {
  rds_endpoint = element(split(":", aws_db_instance.tf_rds_instance.endpoint), 0)
}
output "RDS_Endpoint" {
  value = local.rds_endpoint
}
