provider "aws" {
  region = "eu-north-1"
}
variable "instance_type" {}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
 resource "aws_security_group" "web_sg_https" { 
 name    	= "web_sg_https"
  description = "Allow HTTPS and SSH traffic"

  ingress {
	from_port   = 22
	to_port 	= 22
	protocol	= "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
	from_port   = 443
	to_port 	= 443
	protocol	= "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
	from_port   = 0
	to_port 	= 0
	protocol	= "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "key_mzuiit"
  vpc_security_group_ids = [aws_security_group.web_sg_https.id]
  associate_public_ip_address = true
  tags = {
    Name = "lab2_mzuiit"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo snap install docker
              systemctl enable docker
              systemctl start docker
              sudo chown $USER /var/run/docker.sock
              docker run -d --name my-web-app -p 80:80 collider41/my-web-app:latest
              docker run -d \
                --name watchtower \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --interval 300
              EOF
}
