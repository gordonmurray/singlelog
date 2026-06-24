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

-- An explicit structure is given to s3() so the view can be created even when
-- the bucket is still empty at first boot (no schema to infer yet); missing
-- fields like an absent user default cleanly.
CREATE MATERIALIZED VIEW IF NOT EXISTS logs_recent
REFRESH EVERY 1 MINUTE
TO logs AS
SELECT
    parseDateTimeBestEffortOrNull(timestamp) AS timestamp,
    client,
    user,
    request,
    status,
    size,
    referer,
    agent
FROM s3(tigris,
        url = 'https://t3.storage.dev/@BUCKET@/nginx/**/*.log.gz',
        format = 'JSONEachRow',
        structure = 'client String, user String, request String, status UInt16, size UInt64, referer String, agent String, timestamp String')
WHERE parseDateTimeBestEffortOrNull(timestamp) > now() - INTERVAL 1 DAY;
