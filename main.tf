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
              sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl start docker
sudo systemctl enable docker
docker --version
sudo service docker start
sudo usermod -a -G docker ubuntu

              sudo docker run -d --name my-web-app -p 80:80 collider41/my-web-app:latest
              sudo docker run -d \
                --name watchtower \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --interval 300
              EOF
}
