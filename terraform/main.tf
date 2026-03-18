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

# 4. IDS & WAF용 보안 그룹 (ICMP 규칙 추가)
resource "aws_security_group" "sec_sg" {
  name        = "security-lab-sg-v5" # 이름을 유니크하게 변경
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

  # ✅ IDS 테스트를 위해 Ping(ICMP) 허용 추가
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Kafka 서버용 보안 그룹
resource "aws_security_group" "kafka_sg" {
  name        = "kafka-sg-v2" # 중복 방지를 위해 이름 변경
  vpc_id      = data.aws_vpc.default.id # 하드코딩 대신 data 참조 사용

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
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

# 6. 인스턴스 배포
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sec_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  tags                   = { Name = "WAF-Server" }
}

resource "aws_instance" "ids" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sec_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  tags                   = { Name = "Snort-IDS" }
}

resource "aws_instance" "kafka" {
  ami                    = data.aws_ami.ubuntu.id # AMI 일치
  instance_type          = "t3.small"
  key_name               = var.key_name # 변수 처리로 일관성 유지
  vpc_security_group_ids = [aws_security_group.kafka_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  tags                   = { Name = "Kafka-Broker" }
}

# Outputs
output "server_ip" { value = aws_instance.server.public_ip }
output "ids_ip"    { value = aws_instance.ids.public_ip }
output "kafka_ip"  { value = aws_instance.kafka.public_ip }
