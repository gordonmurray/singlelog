-- Ad-hoc search straight over the logs in Tigris, no ingest needed.
-- The `tigris` named collection (written at boot from Secrets Manager) supplies
-- the credentials; Tigris's free egress makes repeated scans cheap.
--
-- Change the bucket in the URL if you didn't use the default "singlelog-logs".

-- Requests by status code.
SELECT status, count() AS n
FROM s3(tigris, url = 'https://t3.storage.dev/singlelog-logs/nginx/**/*.log.gz', format = 'JSONEachRow')
GROUP BY status
ORDER BY n DESC;

-- Top client IPs.
SELECT client, count() AS hits
FROM s3(tigris, url = 'https://t3.storage.dev/singlelog-logs/nginx/**/*.log.gz', format = 'JSONEachRow')
GROUP BY client
ORDER BY hits DESC
LIMIT 20;

-- Most requested paths.
SELECT request, count() AS hits
FROM s3(tigris, url = 'https://t3.storage.dev/singlelog-logs/nginx/**/*.log.gz', format = 'JSONEachRow')
GROUP BY request
ORDER BY hits DESC
LIMIT 20;

-- Prune by time using the Hive-style partitions so only the relevant
-- objects are scanned.
SET use_hive_partitioning = 1;
SELECT count()
FROM s3(tigris, url = 'https://t3.storage.dev/singlelog-logs/nginx/**/*.log.gz', format = 'JSONEachRow')
WHERE year = '2026' AND month = '06';
