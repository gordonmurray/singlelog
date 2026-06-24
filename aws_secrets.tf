# Tigris credentials live in Secrets Manager. Vector and ClickHouse read them at
# boot; nothing secret is baked into the AMIs or committed to the repo.
resource "aws_secretsmanager_secret" "tigris" {
  name        = var.tigris_secret_name
  description = "Tigris access key for Vector and ClickHouse"

  # 0 so a disposable demo environment re-applies cleanly after a teardown,
  # rather than leaving the secret scheduled for deletion for days.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "tigris" {
  secret_id = aws_secretsmanager_secret.tigris.id
  secret_string = jsonencode({
    access_key_id     = var.tigris_access_key
    secret_access_key = var.tigris_secret_key
  })
}
