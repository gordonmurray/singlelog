# SingleLog

> The last logging solution you'll ever need.

Store logs cheaply on object storage, then search them fast — without keeping a big
database warm. SingleLog ships nginx logs to **Tigris** (S3-compatible, with free
egress) and searches them with **ClickHouse**.

```
nginx + Vector  ──►  Tigris (gzip NDJSON, partitioned)  ──►  ClickHouse (Graviton)
                     the durable log lake                    s3() + a hot MergeTree
```

The trick is **free egress**: querying object storage in place is normally punished by
data-transfer fees, which is why people copy logs into a warm database. Tigris removes
that, so the object store stays the source of truth and ClickHouse is just cheap compute
on top.

## How it works

- **nginx + Vector** (`t4g.micro`) — Vector tails the nginx access log, parses the
  combined format into structured fields, and writes **gzip NDJSON** to Tigris,
  partitioned `year=/month=/day=/hour=`.
- **Tigris** — the durable log lake. The bucket is created by Terraform via the official
  `tigrisdata/tigris` provider.
- **ClickHouse** (`t4g.medium`) — the search layer. It reads logs straight from Tigris
  with `s3()` for ad-hoc and historical queries, and keeps the last day in a refreshable
  MergeTree table for sub-second interactive search.

## Prerequisites

- An AWS account, plus Terraform and Packer.
- A [Tigris](https://www.tigrisdata.com/) account and a bucket access key — see
  [docs/tigris.md](docs/tigris.md).

## Setup

1. **Build the images** (one per host):

   ```sh
   cd packer
   cp variables.pkrvars.hcl.example variables.pkrvars.hcl   # fill in vpc/subnet/region
   packer init nginx.pkr.hcl && packer build -var-file=variables.pkrvars.hcl nginx.pkr.hcl
   packer init clickhouse.pkr.hcl && packer build -var-file=variables.pkrvars.hcl clickhouse.pkr.hcl
   ```

2. **Configure Terraform:**

   ```sh
   cp terraform.tfvars.example terraform.tfvars   # set my_ip_address, vpc/subnet, Tigris key
   ```

3. **Apply:**

   ```sh
   terraform init
   terraform apply
   ```

Terraform creates the Tigris bucket, stores the Tigris key in Secrets Manager, and stands
up the two instances. Each instance reads the key at boot.

## Searching

Connect to the ClickHouse box (`clickhouse-client`, or HTTP on port 8123 from your IP)
and query the hot table or Tigris directly:

```sql
-- instant, from the hot MergeTree
SELECT status, count() FROM logs GROUP BY status;

-- straight from Tigris, any time range
SELECT client, count() AS hits
FROM s3(tigris, url = 'https://t3.storage.dev/singlelog-logs/nginx/**/*.log.gz',
        format = 'JSONEachRow')
GROUP BY client ORDER BY hits DESC LIMIT 20;
```

More in [docs/clickhouse.md](docs/clickhouse.md) and `packer/files/clickhouse/queries.sql`.

## Cost

Roughly **~$37/mo** of AWS (nginx + ClickHouse + Secrets Manager) plus Tigris storage,
down from ~$201/mo — see [MODERNIZATION.md](MODERNIZATION.md). `make cost` runs an
Infracost breakdown.

## Validate

CINC Auditor profiles confirm the instances are healthy after apply:

```sh
make audit-nginx      HOST=<nginx_ip>      KEY=~/.ssh/id_rsa
make audit-clickhouse HOST=<clickhouse_ip> KEY=~/.ssh/id_rsa
```

## Development

`make validate` (Terraform), `make lint` (tflint), `make security` (Trivy). CI runs the
same on every PR; the toolchain is pinned in a Docker image (`make shell`).
