data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "lab" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [
  aws_security_group.lab.id
  ]

user_data = <<EOF
#!/bin/bash

apt update -y
apt install -y git

cd /home/ubuntu

git clone https://github.com/YOUR_ID/cloud-sec-lab.git

bash cloud-sec-lab/scripts/install.sh

EOF

  tags = {
    Name = "lab-instance"
  }
}
