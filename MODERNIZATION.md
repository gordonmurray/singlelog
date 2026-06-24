# Modernization

singlelog from 2022 still had a good idea — store logs cheaply on object storage,
then search them — wrapped around an expensive, dated stack. This is what changed
and why.

## Original (2022)

```
nginx + Vector  ──►  AWS S3 (uncompressed text)  ──►  SingleStore (t3.xlarge)
```

- Vector tailed nginx logs and shipped **uncompressed text** to S3, batched, under a
  flat `nginx/` prefix.
- **SingleStore** on an always-on `t3.xlarge` was the search layer (~$133/mo, 66% of
  the bill). The whole point of logs-on-object-storage is to *not* keep a big database
  warm.
- Terraform 1.2.3, AWS provider 4.20, Packer JSON, a 2018 MemSQL apt key, a wildcard
  S3 IAM policy. Estimated ~$201/mo.

## What we kept

- **Vector** — still the best-in-class log collector.
- **Object storage as the lake** — the right call; storage decoupled from compute.
- **The IaC discipline** — Terraform + Packer + Infracost + post-apply checks.

## What we threw out

- **SingleStore** — the always-on cost that defeated "cost effective".
- **Uncompressed, unpartitioned text** — expensive to store and slow to scan.
- **Dead pins and a committed profile name.**

## New architecture

```
nginx + Vector  ──►  Tigris (gzip NDJSON, partitioned)  ──►  ClickHouse (Graviton)
                     free egress                              s3() + hot MergeTree
```

- **Tigris** instead of AWS S3. It's S3-compatible with **free egress**, which is the
  economic key: querying object storage *in place* is normally punished by egress fees,
  so people copy logs into a warm database. Free egress removes that, so the object
  store can stay the queryable source of truth.
- Vector writes **gzip NDJSON**, partitioned `year=/month=/day=/hour=`, parsing the
  nginx combined format into structured fields.
- **ClickHouse** on a small `t4g.medium` Graviton box is the search layer:
  - `s3()` federation reads logs straight from Tigris for ad-hoc / historical search;
  - a refreshable MergeTree holds the recent window for sub-second interactive search.
- The bucket is real IaC via the official `tigrisdata/tigris` provider; the Tigris key
  lives in Secrets Manager and the instances read it at boot.

## Cost

| | Old | New |
| --- | --- | --- |
| Search compute | SingleStore t3.xlarge ~$133 | ClickHouse t4g.medium ~$29 |
| Log source | nginx t4g.micro ~$7 | nginx t4g.micro ~$7 |
| Object storage | S3 + ~$27 Select scanning | Tigris, **free egress** |
| **Total** | **~$201/mo** | **~$37/mo AWS + Tigris storage** |

## Tooling

Terraform 1.x + AWS provider 6, Packer HCL2, Trivy (Security tab), CINC Auditor checks,
a pinned toolchain image, CI with a required `terraform` check, auto-merge, and
Dependabot.
