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

 type    = string

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
              yum install -y docker
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
