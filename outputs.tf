output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}

output "singlestore_ip" {
  value = aws_instance.singlestore.public_ip
}
