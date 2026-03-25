resource "aws_security_group" "ids_sg" {
  name        = "ids-security-group"
  description = "Allow all inbound traffic for IDS testing"
  vpc_id      = aws_vpc.main.id # 본인의 VPC ID 변수명

  # 인바운드 규칙: 모든 포트, 모든 프로토콜 개방
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1은 모든 프로토콜(TCP, UDP, ICMP 등)을 의미합니다.
    cidr_blocks = ["0.0.0.0/0"] # 전 세계 어디서든 접속 허용
  }

  # 아웃바운드 규칙: 기본적으로 모두 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ids-sg-testing"
  }
}