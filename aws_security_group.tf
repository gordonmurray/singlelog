resource "aws_security_group" "nginx" {
  name        = "nginx"
  description = "nginx security group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "clickhouse" {
  name        = "clickhouse"
  description = "clickhouse security group"
  vpc_id      = var.vpc_id
}