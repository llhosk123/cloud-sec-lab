resource "aws_security_group" "main" {
  name_prefix = "lab-sg-testing"

  # [테스트용] 모든 인바운드 트래픽 허용 (TCP, UDP, ICMP 전체)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 기존 22, 80, 30000-32767 포트들은 위 규칙에 모두 포함되므로 삭제해도 무방합니다.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-sg-all-open"
  }
}