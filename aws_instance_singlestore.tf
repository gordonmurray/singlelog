data "aws_ami" "singlestore" {
  most_recent = true

  filter {
    name   = "name"
    values = ["singlestore*"]
  }

  owners = [var.aws_account_id]
}

resource "aws_instance" "singlestore" {
  ami                     = data.aws_ami.singlestore.id
  instance_type           = "t3.xlarge"
  key_name                = aws_key_pair.key.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [aws_security_group.singlestore.id]
  disable_api_termination = true

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = "10"
  }

  tags = {
    Name = "singlestore"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

}
