# Storage on Tigris

Logs are stored on [Tigris](https://www.tigrisdata.com/), an S3-compatible object
store with **free egress** — which is what makes querying the logs in place from
ClickHouse cost-effective (repeated scans aren't penalised by data-transfer fees).

## One-time setup: a Tigris access key

The bucket itself is created by Terraform, but you need a Tigris access key first
(this is the one step Terraform can't do for you):

1. Create a Tigris account and a bucket access key in the
   [Tigris dashboard](https://www.tigrisdata.com/docs/get-started/).
2. Put the key in `terraform.tfvars` (gitignored):

   ```hcl
   tigris_access_key  = "tid_..."
   tigris_secret_key  = "tsec_..."
   tigris_bucket_name = "singlelog-logs"   # must be globally unique
   ```

That's it. On `terraform apply`:

- the `tigris_bucket` resource creates the bucket (private, standard tier);
- the same key is stored in AWS Secrets Manager so the nginx/Vector and ClickHouse
  instances can read it at boot.

## Endpoint

Tigris uses a single global endpoint and the literal region `auto`:

| Setting | Value |
| --- | --- |
| Endpoint | `https://t3.storage.dev` |
| Region | `auto` |

Vector's S3 sink and ClickHouse's `s3()` calls both point here.

## Storage tiers and lifecycle

Tigris has storage tiers (cheapest → hottest): Archive, Archive Instant (`GLACIER_IR`),
Infrequent Access (`STANDARD_IA`), Standard. Egress is free, but **colder tiers cost
more to retrieve**, so keep recently-searched partitions on Standard and age older ones
down.

The bucket's `default_storage_tier` is `STANDARD`. Time-based **lifecycle rules** (to
transition old `year=…/month=…` partitions to colder tiers and eventually expire them)
aren't supported by the Terraform provider yet
([tigrisdata/terraform-provider-tigris#28](https://github.com/tigrisdata/terraform-provider-tigris/issues/28)).
Until that lands you can apply a rule directly against the Tigris endpoint:

```bash
aws s3api put-bucket-lifecycle-configuration \
  --endpoint-url https://t3.storage.dev --region auto \
  --bucket singlelog-logs \
  --lifecycle-configuration '{
    "Rules": [{
      "ID": "age-logs",
      "Filter": {"Prefix": "nginx/"},
      "Status": "Enabled",
      "Transitions": [
        {"Days": 30, "StorageClass": "STANDARD_IA"},
        {"Days": 90, "StorageClass": "GLACIER_IR"}
      ],
      "Expiration": {"Days": 365}
    }]
  }'
```
