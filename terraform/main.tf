provider "aws" {
  region = "ap-northeast-2"
}

variable "key_name" {}

# 1. 기존의 Default VPC 정보 가져오기
data "aws_vpc" "default" {
  default = true
}

# 2. Default VPC에 속한 서브넷들 가져오기
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. 최신 Ubuntu 22.04 AMI 찾기
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 4. 보안 그룹 (기존 VPC ID 사용)
resource "aws_security_group" "sec_sg" {
  name        = "security-test-sg-v2" # 이름을 살짝 바꿔 충돌 방지
  vpc_id      = data.aws_vpc.default.id
  
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

# 5. EC2 인스턴스 (Server: K3s + WAF)
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sec_sg.id]
  # 첫 번째 기본 서브넷 사용
  subnet_id              = data.aws_subnets.default.ids[0]
  tags                   = { Name = "WAF-Server" }
}

# 6. EC2 인스턴스 (IDS: Snort)
resource "aws_instance" "ids" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sec_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  tags                   = { Name = "Snort-IDS" }
}

# Outputs
output "server_ip" { value = aws_instance.server.public_ip }
output "ids_ip"    { value = aws_instance.ids.public_ip }
