# The log lake. Tigris is S3-compatible with free egress, which is what makes
# querying the logs in place (from ClickHouse) cost-effective.
resource "tigris_bucket" "logs" {
  bucket               = var.tigris_bucket_name
  default_storage_tier = "STANDARD"
}

resource "tigris_bucket_public_access" "logs" {
  bucket              = tigris_bucket.logs.bucket
  acl                 = "private"
  public_list_objects = false
}
