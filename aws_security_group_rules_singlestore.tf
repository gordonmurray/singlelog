resource "aws_security_group_rule" "singlestore_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.singlestore.id
  description       = "Self"
}

resource "aws_security_group_rule" "singlestore_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.singlestore.id
  description       = "HTTP"
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

resource "aws_security_group_rule" "singlestore_sql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip_address}/32"]
  security_group_id = aws_security_group.singlestore.id
  description       = "SQL access"
}

resource "aws_security_group_rule" "singlestore_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx.id
  security_group_id        = aws_security_group.singlestore.id
  description              = "Application access"
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
