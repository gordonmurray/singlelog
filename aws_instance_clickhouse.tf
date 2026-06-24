data "aws_ami" "clickhouse" {
  most_recent = true

  filter {
    name   = "name"
    values = ["clickhouse*"]
  }

  owners = [var.aws_account_id]
}

resource "aws_instance" "clickhouse" {
  ami                    = data.aws_ami.clickhouse.id
  instance_type          = "t4g.medium"
  key_name               = aws_key_pair.key.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.clickhouse.id]
  iam_instance_profile   = aws_iam_instance_profile.singlelog_profile.name

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
    volume_type           = "gp3"
  }

  # Read the Tigris key from Secrets Manager and write it into a ClickHouse
  # named collection so s3() queries can reach Tigris without inline secrets.
  user_data = <<EOF
#!/bin/bash
set -e
secret=$(aws secretsmanager get-secret-value --secret-id ${var.tigris_secret_name} --query SecretString --output text --region ${var.aws_region})
cat >/etc/clickhouse-server/config.d/tigris.xml <<XML
<clickhouse>
  <named_collections>
    <tigris>
      <access_key_id>$(echo "$secret" | jq -r .access_key_id)</access_key_id>
      <secret_access_key>$(echo "$secret" | jq -r .secret_access_key)</secret_access_key>
    </tigris>
  </named_collections>
</clickhouse>
XML
chown clickhouse:clickhouse /etc/clickhouse-server/config.d/tigris.xml
chmod 600 /etc/clickhouse-server/config.d/tigris.xml
systemctl restart clickhouse-server
# Wait for ClickHouse, then create the hot MergeTree table + refreshable view.
for i in $(seq 1 30); do clickhouse-client -q 'SELECT 1' >/dev/null 2>&1 && break || sleep 2; done
sed "s|@BUCKET@|${var.tigris_bucket_name}|g" /home/ubuntu/schema.sql | clickhouse-client -mn
EOF

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "clickhouse"
  }
}
