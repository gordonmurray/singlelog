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
  iam_instance_profile    = aws_iam_instance_profile.singlelog_profile.name

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = "10"
  }

  # Pull the Tigris key from Secrets Manager and hand it to Vector's S3 sink.
  user_data = <<EOF
#!/bin/bash
set -e
secret=$(aws secretsmanager get-secret-value --secret-id ${var.tigris_secret_name} --query SecretString --output text --region ${var.aws_region})
cat >/etc/default/vector <<ENV
AWS_ACCESS_KEY_ID=$(echo "$secret" | jq -r .access_key_id)
AWS_SECRET_ACCESS_KEY=$(echo "$secret" | jq -r .secret_access_key)
AWS_REGION=auto
ENV
systemctl restart vector
EOF

  tags = {
    Name = "nginx"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

}

resource "aws_iam_instance_profile" "singlelog_profile" {
  name = "singlelog_profile"
  role = aws_iam_role.instance.name
}
