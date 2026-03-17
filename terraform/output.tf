#output "public_ip" {
#  value = aws_instance.lab.public_ip
#}
output "server_ip" {
  value = aws_instance.server.public_ip
}

output "ids_ip" {
  value = aws_instance.ids.public_ip
}
