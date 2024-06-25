provider "aws" {
  region = "us-north-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0e01839fe06de63f6"
  instance_type = "t3.micro"
  key_name      = "key_mzuiit"

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker pull collider41/my-web-app:latest
              docker pull containrrr/watchtower
              docker run -d --name my-web-app -p 80:80 collider41/my-web-app:latest
              docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower my-web-app --interval 300
              EOF

  tags = {
    Name = "web-instance"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

