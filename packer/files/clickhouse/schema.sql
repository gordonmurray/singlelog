-- Hot window: a MergeTree table holding the last day of logs for sub-second
-- interactive search, rebuilt from Tigris every minute by a refreshable
-- materialized view. Free egress makes the periodic rescan of the recent
-- partitions cheap. @BUCKET@ is replaced with the Tigris bucket name at boot.

CREATE TABLE IF NOT EXISTS logs
(
    timestamp DateTime,
    client    String,
    user      String,
    request   String,
    status    UInt16,
    size      UInt64,
    referer   String,
    agent     String
)
ENGINE = MergeTree
ORDER BY (timestamp);

CREATE MATERIALIZED VIEW IF NOT EXISTS logs_recent
REFRESH EVERY 1 MINUTE
TO logs AS
SELECT
    parseDateTimeBestEffortOrNull(toString(timestamp)) AS timestamp,
    client,
    user,
    request,
    toUInt16OrZero(toString(status)) AS status,
    toUInt64OrZero(toString(size))   AS size,
    referer,
    agent
FROM s3(tigris, url = 'https://t3.storage.dev/@BUCKET@/nginx/**/*.log.gz', format = 'JSONEachRow')
WHERE parseDateTimeBestEffortOrNull(toString(timestamp)) > now() - INTERVAL 1 DAY;
