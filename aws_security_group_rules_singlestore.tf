resource "aws_security_group_rule" "singlestore_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.singlestore.id
  description       = "HTTPS"
}

resource "aws_security_group_rule" "singlestore_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.singlestore.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "singlestore_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.singlestore.id
  description       = "Allow all out"
}
