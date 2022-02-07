terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

provider "aws" {
  profile = var.profile
  region  = "us-east-1"
}

#Getting AMI ID for the latest Amazon Linux 2 from SSM endpoint
data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Creating keypair for instances from keys on my local system
resource "aws_key_pair" "key" {
  key_name   = "main-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Creating bastion host for ansible access to private subnet
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.dmz-sg.id]
  subnet_id                   = aws_subnet.subnet1-pub.id
  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok  --instance-ids ${self.id} \
&& ansible-playbook --extra-vars 'bastion_hostname=${self.public_dns}' bastion_ssh_setup.yml
EOF
  }
  tags = {
    Name = "bastion-host"
  }
}

#Creating 1st webserver on private subnet
resource "aws_instance" "webserver1" {
  ami                    = data.aws_ssm_parameter.linuxAmi.value
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.priv-sg.id]
  subnet_id              = aws_subnet.subnet-priv.id
  private_ip             = "10.0.3.100"
  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok  --instance-ids ${self.id} \
&& ansible-playbook --extra-vars 'host=tag_Name_${self.tags.Name}' webserver.yml
EOF
  }

  tags = {
    Name = "webserver1"
  }
  depends_on = [aws_instance.bastion_host]
}


# #Creating 2nd webserver on private subnet
# resource "aws_instance" "webserver2" {
#   ami                    = data.aws_ssm_parameter.linuxAmi.value
#   instance_type          = "t3.micro"
#   key_name               = aws_key_pair.key.key_name
#   vpc_security_group_ids = [aws_security_group.priv-sg.id]
#   subnet_id              = aws_subnet.subnet2-priv.id
#   private_ip             = "10.0.4.100"
#   provisioner "local-exec" {
#     command = <<EOF
# aws --profile ${var.profile} ec2 wait instance-status-ok  --instance-ids ${self.id} \
# && ansible-playbook --extra-vars 'host=tag_Name_${self.tags.Name}' webserver.yml
# EOF
#   }

#   tags = {
#     Name = "webserver2"
#   }
#   depends_on = [aws_instance.bastion_host]
# }


# #Creating db subnet group
# resource "aws_db_subnet_group" "dbgroup" {
#   name       = "db-subnet-grop"
#   subnet_ids = [aws_subnet.subnet-priv.id, aws_subnet.subnet2-priv.id]
#   tags = {
#     Name = "MyDBsubnetgroup"
#   }
# }

# #Creating mysql RDS instance on private subnet
# resource "aws_db_instance" "dbserver" {
#   allocated_storage      = 20
#   engine                 = "mysql"
#   engine_version         = "8.0.20"
#   instance_class         = "db.t3.micro"
#   name                   = "webappdb"
#   identifier             = "databaseserver1"
#   username               = "admin"
#   parameter_group_name   = "default.mysql8.0"
#   password               = "password"
#   skip_final_snapshot    = true
#   db_subnet_group_name   = aws_db_subnet_group.dbgroup.id
#   vpc_security_group_ids = [aws_security_group.priv-sg.id]
#   port                   = 3306
#   tags = {
#     Name = "dbserver"
#   }
# }

