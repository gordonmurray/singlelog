resource "aws_key_pair" "key" {
  key_name   = "singlelog"
  public_key = file(pathexpand(var.ssh_public_key_path))
}