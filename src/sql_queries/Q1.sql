/* Over time, how has the average taxi fare per mile changed, taking inflation into 
account? 
FOR DATE REFERENCE WE TAKE THE TRIP START TIMESTAMP SOME TRIPS MIGHT OVERLAP DAYS, MONTHS OR YEARS*/


WITH time_format AS(
SELECT
  CAST(DATETIME_TRUNC(taxi.trip_start_timestamp, MONTH) AS DATE) AS date_formatted
  ,taxi.fare
  ,taxi.tips
  ,CASE WHEN taxi.tolls IS NULL THEN 0 ELSE taxi.tolls END AS tolls -- Tolls has NULL values
  ,taxi.extras
  ,taxi.trip_total
  ,taxi.trip_miles
  ,taxi.trip_seconds
FROM `big-data-taxis-416219.taxi.taxi_cleaned` as taxi
)
, aggregated AS(
  SELECT 
    tf.date_formatted
    ,SUM(tf.fare) AS sum_fare
    ,SUM(tf.tips) AS sum_tips
    ,SUM(tf.tolls) AS sum_tolls
    ,SUM(tf.extras) AS sum_extras
    ,SUM(tf.trip_total) AS sum_trip_total
    ,SUM(tf.trip_miles) AS sum_trip_miles
    ,SUM(tf.trip_seconds) AS sum_trip_seconds
    ,COUNT(*) AS number_of_trips
  FROM time_format as tf
  WHERE tf.date_formatted < '2019-01-01' -- After this date the trip count is not reliable or representative.
  GROUP BY date_formatted
)
SELECT
  a.date_formatted
  ,a.number_of_trips
  ,a.sum_fare
  ,a.sum_tips
  ,a.sum_tolls
  ,a.sum_extras
  ,a.sum_trip_total
  ,a.sum_trip_miles
  ,a.sum_trip_seconds
  ,d.deflator_base_jan_13
FROM aggregated AS a
  INNER JOIN `big-data-taxis-416219.taxi.chicago_cpi_deflator_cleaned` AS d
    ON a.date_formatted = d.cpi_date
ORDER BY a.date_formatted;