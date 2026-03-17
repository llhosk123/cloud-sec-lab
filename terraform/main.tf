# terraform/main.tf
provider "aws" {
  region = "ap-northeast-2"
}

variable "key_name" {}

# VPC 및 보안 그룹 설정
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sec_sg" {
  vpc_id = aws_vpc.main.id
  
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

# 인스턴스 설정 (Ubuntu 22.04 LTS)
resource "aws_instance" "server" {
  ami           = "ami-04cebc8d05cc11912" # Ubuntu 22.04 LTS ap-northeast-2
  instance_type = "t3.small"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sec_sg.id]
  subnet_id     = aws_subnet.public.id
  tags = { Name = "WAF-Server" }
}

resource "aws_instance" "ids" {
  ami           = "ami-04cebc8d05cc11912"
  instance_type = "t3.small"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sec_sg.id]
  subnet_id     = aws_subnet.public.id
  tags = { Name = "Snort-IDS" }
}

output "server_ip" { value = aws_instance.server.public_ip }
output "ids_ip"    { value = aws_instance.ids.public_ip }
