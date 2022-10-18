resource "aws_kms_key" "s3" {
  enable_key_rotation = true
}