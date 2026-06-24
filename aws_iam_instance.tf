# Instance role: the EC2 boxes may read only the Tigris secret, nothing else.
# This replaces the old wildcard S3 write policy (removed once storage moves to
# Tigris).
resource "aws_iam_role" "instance" {
  name = "singlelog-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "singlelog-instance"
  }
}

resource "aws_iam_role_policy" "read_tigris_secret" {
  name = "read-tigris-secret"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.tigris.arn
    }]
  })
}
