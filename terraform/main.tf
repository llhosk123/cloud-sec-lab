provider "aws" {
  region = "ap-northeast-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "server" {

  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.lab.id
  ]

  tags = {
    Name = "lab-instance"
  }
}

resource "aws_instance" "ids" {
  ami           = var.ami
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "ids"
  }
}
