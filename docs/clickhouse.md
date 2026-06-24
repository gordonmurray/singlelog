# Searching the logs with ClickHouse

ClickHouse is the search layer. It reads the logs straight out of Tigris, so the
object store is the source of truth and ClickHouse is just compute on top.

## Connecting

From the ClickHouse box:

```sh
clickhouse-client
```

Or over HTTP from your own machine (port 8123 is open to your IP):

```sh
curl "http://<clickhouse_ip>:8123/" --data-binary @packer/files/clickhouse/queries.sql
```

## Querying Tigris in place

The `tigris` named collection holds the Tigris credentials (written at boot from
Secrets Manager), so queries don't carry secrets. Point `s3()` at the bucket:

```sql
SELECT status, count()
FROM s3(tigris, url = 'https://t3.storage.dev/singlelog-logs/nginx/**/*.log.gz',
        format = 'JSONEachRow')
GROUP BY status;
```

`packer/files/clickhouse/queries.sql` has a few worked examples. Because the logs
are partitioned `year=…/month=…/day=…/hour=…`, set `use_hive_partitioning = 1` and
filter on those columns to scan only the objects you need.

This federated mode is ideal for ad-hoc and historical search — free egress means
you're not penalised for scanning Tigris repeatedly. For sub-second interactive
search over the recent window, see the MergeTree table.
