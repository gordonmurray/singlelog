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
    volume_size           = "100"
    volume_type           = "gp3"
  }

  user_data = <<EOF
#!/bin/bash
# Some settings needed by Singlestore
sudo sysctl -w vm.min_free_kbytes=161950
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w net.core.rmem_max=8388608
sudo sysctl -w net.core.wmem_max=8388608
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# Start the UI on port 8080
sudo memsql-studio
EOF

  tags = {
    Name = "singlestore"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

}
