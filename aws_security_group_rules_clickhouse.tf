resource "aws_security_group_rule" "clickhouse_http" {
  type              = "ingress"
  from_port         = 8123
  to_port           = 8123
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.clickhouse.id
  description       = "ClickHouse HTTP from me"
}

resource "aws_security_group_rule" "clickhouse_native" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.clickhouse.id
  description       = "ClickHouse native from me"
}

resource "aws_security_group_rule" "clickhouse_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.clickhouse.id
  description       = "SSH from me"
}

resource "aws_security_group_rule" "clickhouse_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clickhouse.id
  description       = "Allow all out"
}
