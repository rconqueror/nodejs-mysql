/*
1. ec2 instance resource
2. new security group:
    - 22 ssh
    - 443 https
    - 3000 http, nodejs to access the app
*/
##Creating ssh key pair for ec2 instance
resource "tls_private_key" "tf_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "tf_ec2_key_pair" {
  key_name   = "my-terraform-key" # Unique name
  public_key = tls_private_key.tf_ec2_key.public_key_openssh
  lifecycle {
    ignore_changes        = [key_name]
    create_before_destroy = true
  }
}

resource "local_file" "private_key" {
  content  = tls_private_key.tf_ec2_key.private_key_pem
  filename = "${pathexpand("~/.ssh")}\\my-terraform-key.pem"
  lifecycle {
    ignore_changes = [content]
  }
}

## Creating Security Group
#resource "aws_security_group" "tf_ec2_sg" {
#  name        = "nodejs-server-sg"
#  description = "Security group for Nodejs EC2 instance"
#  vpc_id      = var.vpc_id
#
#  ingress {
#    description = "TLS from VPC"
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    description = "SSH"
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    description = "TCP for Nodejs"
#    from_port   = 3000
#    to_port     = 3000
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}

## Creating security group from module
module "tf_sg_module" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "5.2.0"
  name                = "ec2-instance-sg"
  description         = "Security group from module for EC2 instance"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "ssh-tcp", "http-80-tcp"]
  #ingress_with_cidr_blocks = [
  #  {
  #    from_port   = 3000
  #    to_port     = 3000
  #    protocol    = "tcp"
  #    description = "TCP for nodejs app"
  #    cidr_blocks = "0.0.0.0/0"
  #  },
  #]
  egress_rules = ["all-all"]
}

## Creating EC2 instance
resource "aws_instance" "tf_ec2_instance" {
  ami                         = "ami-0ecb62995f68bb549"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  key_name                    = aws_key_pair.tf_ec2_key_pair.key_name
  vpc_security_group_ids      = [module.tf_sg_module.security_group_id] #[aws_security_group.tf_ec2_sg.id]
  user_data = templatefile("${path.module}/user-data.tftpl", {
    db_host = local.rds_endpoint
    db_user = aws_db_instance.tf_rds_instance.username
    db_pass = aws_db_instance.tf_rds_instance.password
    db_name = aws_db_instance.tf_rds_instance.db_name
  })
  user_data_replace_on_change = true
  depends_on                  = [aws_s3_bucket.tf_s3_bucket] # attach s3 bucket
  tags = {
    Name = "Nodejs-Server"
  }
}
resource "aws_eip_association" "tf_ec2_eip_assoc" {
  instance_id   = aws_instance.tf_ec2_instance.id
  allocation_id = "eipalloc-062762d54acf57e0e"
}

output "ec2_public_ip" {
  value = "ssh -i C:\\Users\\rahul\\.ssh\\my-terraform-key.pem ubuntu@${aws_instance.tf_ec2_instance.public_ip}"
}

