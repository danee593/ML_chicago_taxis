/* takes a sample of 1 percent, useful for plotting relationships between some variables and train a local model */
SELECT
  CASE WHEN t.tips > 0 THEN 1 ELSE 0 END AS tips_encoded
  ,t.trip_start_timestamp
  ,t.trip_end_timestamp
  ,t.trip_seconds
  ,t.trip_miles
  ,t.pickup_community_area
  ,t.dropoff_community_area
  ,t.fare
  ,CASE WHEN t.tolls IS NULL THEN 0 ELSE t.tolls END AS tolls
  ,t.extras
  ,t.payment_type
FROM `big-data-taxis-416219.taxi.taxi_cleaned` AS t
TABLESAMPLE SYSTEM (0.01 PERCENT);