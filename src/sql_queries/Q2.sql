/*2.	In Chicago, which months historically see the highest volume of taxi trips?*/

SELECT
  FORMAT_TIMESTAMP("%B",t.trip_start_timestamp) AS month_name
  ,COUNT(*) AS trip_count
FROM
  `big-data-taxis-416219.taxi.taxi_cleaned` AS t
WHERE t.trip_start_timestamp < '2019-01-01 00:00:00' -- After this date the trip count is not reliable or representative.
GROUP BY FORMAT_TIMESTAMP("%B",t.trip_start_timestamp)
ORDER BY trip_count DESC;
