output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}

output "clickhouse_ip" {
  value = aws_instance.clickhouse.public_ip
}

output "logs_bucket" {
  value = tigris_bucket.logs.bucket
}
