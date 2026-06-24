# Packer images

HCL2 templates, both built on Ubuntu 24.04 (arm64) from a Canonical AMI lookup:

- `nginx.pkr.hcl` — nginx + Vector (the log source)
- `clickhouse.pkr.hcl` — ClickHouse (the search layer)

Copy the vars file and fill in your VPC/subnet/region/profile:

```sh
cp variables.pkrvars.hcl.example variables.pkrvars.hcl
```

Then build:

```sh
packer init nginx.pkr.hcl
packer build -var-file=variables.pkrvars.hcl nginx.pkr.hcl
packer build -var-file=variables.pkrvars.hcl clickhouse.pkr.hcl
```
