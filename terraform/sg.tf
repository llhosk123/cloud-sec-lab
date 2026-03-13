resource "aws_security_group" "lab" {
  count = var.existing_sg_id == "" ? 1 : 0

  name        = "lab-sg"
  description = "Security group for cloud-sec-lab"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ... 나머지 포트 설정 (80, 30000-32767) ...

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
