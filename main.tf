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
variable "security_group_id" {
 type	= string
 default = "sg-0ddff07b4d83363cf"
}

data "aws_security_group" "selected" {
 id = var.security_group_id
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "key_mzuiit"
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  associate_public_ip_address = true
  tags = {
    Name = "lab2_mzuiit"
  }
    user_data = <<-EOF
	#!/bin/bash
	# install and configure docker on the ec2 instance
	# Add Docker's official GPG key:
sudo echo 'APT::Get::Assume-Yes;' | sudo tee -a /etc/apt/apt.conf.d/00Do-not-ask
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https
sudo install -y -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras libltdl7 libslirp0 pigz
  slirp4netns        
sudo docker run -d --name my-web-app -p 80:80 collider41/my-web-app:latest
        sudo docker run -d \
                --name watchtower \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --interval 300
        EOF
}
