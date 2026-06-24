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
search over the recent window, see the MergeTree table below.

## Hot window in a MergeTree

Federation is great for history, but scanning object storage has latency. For
sub-second interactive search the box keeps the **last day** of logs in a local
MergeTree table, `logs`, rebuilt from Tigris every minute by a refreshable
materialized view (`packer/files/clickhouse/schema.sql`, created at boot):

```sql
SELECT status, count() FROM logs GROUP BY status;          -- instant
SELECT * FROM logs WHERE request LIKE '%/login%' ORDER BY timestamp DESC LIMIT 50;
```

The view rebuilds the table each minute, so there are no duplicates and the window
always reflects recent Tigris data. Widen the `INTERVAL 1 DAY` in `schema.sql` to
keep more, at the cost of a larger periodic rescan (cheap on Tigris — egress is
free). Tigris stays the source of truth; the MergeTree is just a fast cache.
