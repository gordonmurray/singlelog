resource "aws_s3_bucket" "logs" {
  bucket = "singlelogs-logs"

  tags = {
    Name = "singlelogs-logs"
  }
}

resource "aws_s3_bucket_acl" "logs_acl" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}
