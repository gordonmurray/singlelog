data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["nginx*"]
  }

  owners = [var.aws_account_id]
}

resource "aws_instance" "nginx" {
  ami                     = data.aws_ami.nginx.id
  instance_type           = "t4g.micro"
  key_name                = aws_key_pair.key.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [aws_security_group.nginx.id]
  disable_api_termination = true

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = "10"
  }

  tags = {
    Name = "nginx"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

}
