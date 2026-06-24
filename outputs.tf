output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}

output "singlestore_ip" {
  value = aws_instance.singlestore.public_ip
}

output "logs_bucket" {
  value = tigris_bucket.logs.bucket
}
