/* Data cleansing, this will be saved as a materialized View initial row count: 102,589,284   
1. Fare has inconsistencies:
  1.1 minimum fare is 3.25 in Chicago --> 1,159,819 rows eliminated note that this filter will also eliminate
      null fares (three point logic) 2,821 rows. Rows after first transformation: 101,426,644
  1.2 the total fare + tips + tolls + extras != trip_total (tolerance +- 1.0) --> 31,972 rows eliminated
      rows after transformation: 101394672
  1.3 unusual high values in fare 4*sd + avg --> 23,655 rows eliminated plus some rows filtering high tips
      rows after: 101371014
      unusual high total values > 300 with low milleage (between 0 and 1) --> 101370207
2. Mileage has inconsistencies:
  if fare > 5 and mileage 0 and seconds --> 175,633 plus nulls result 101,167,407
3. Seconds diff between start time and end time is really high.
  probably the correct approach would be to filter out NULLS 16042 and after abs(diff in seconds) > 900
  there's not so many observations, still quite a lot. But decreases a lil bit 13.33 minutes.
4. final touches no extra fees greater than 1000.
5. some distances does not make sense when looking at the coordinates.
  Almost no trips will follow a straight line. Therefore, the distance between two GEOM POINTS
  calculated as ST_DISTANCE() must be lower or equal to the distance given by the table.
  If the calculated distance is greater thatn the distance given by the table by more than 10 miles drop them.
  drop --> 720,672 rows -> cleaned table 96494038.
6. Finally, drop the 5 rows that have a null value on the trip_miles
cleaned table 96,494,033: 94.05% of the table usable.

V1. Author: Daniel Enriquez 
2024-03-05
*/

-- 1 Fare inconsistency
-- 1.1 minimum fare

CREATE OR REPLACE TABLE  `big-data-taxis-416219.taxi.taxi_cleaned` AS
SELECT *
FROM(

WITH minimum_fare AS(
  SELECT *
  FROM `big-data-taxis-416219.taxi.taxi_trips` AS taxi
  WHERE taxi.fare >= 3.25
)
, total_fare_1 AS(
  SELECT
    *
    ,CASE
    WHEN mf.tolls IS NULL THEN (mf.fare + mf.tips + mf.extras)
    ELSE (mf.fare + mf.tips + mf.tolls + mf.extras)
    END AS total_calculated
  FROM minimum_fare as mf
)
, total_fare_2 AS(
SELECT
  *
FROM total_fare_1 AS f1
WHERE (f1.total_calculated - f1.trip_total) BETWEEN -1.0 AND 1.0
)

--col	row_n	min	avg	std	max
--fare	0	3.25	13.38	53.92	9999.0
--tips	1	0.0	1.39	2.66	930.0
--extras	3	0.0	0.97	11.14	9877.12
--tolls	2	0.0	0.01	0.92	2415.52

-- the fare follows a exponential distribution, taking the log it's close to normal
-- drop the values that are above 3*sd(fare)+avg(fare) = 175.14
-- drop the values that are above 850 for tips (the rest seems to make sense to naked eye)
-- drop the values that are above 500 trip_total

, high_values AS(
  SELECT
    *
  FROM total_fare_2 AS f2
  WHERE f2.fare < 229.06
)
, high_tips AS(
  SELECT
    *
  FROM high_values AS hv
  WHERE hv.tips < 850
)
, high_total AS(  
  SELECT -- 807 records --> 101,370,207
    ht.unique_key
  FROM high_tips AS ht
  WHERE ht.total_calculated > 300
    AND ht.trip_miles BETWEEN 0.0 AND 1.0
)
, high_total_2 AS(
  SELECT
    *
  FROM high_tips AS ht
  WHERE ht.unique_key NOT IN (SELECT * FROM high_total)
)
, mileage AS(
  SELECT
    * -- 175,633 filtered out
  FROM high_total_2 AS ht2
  WHERE NOT(ht2.trip_miles = 0 AND
    ht2.fare > 7.25 AND
    ht2.trip_seconds BETWEEN 0 AND 50)
)
, time_df AS(
SELECT
  *
FROM mileage
WHERE ABS(ROUND((TIMESTAMP_DIFF(trip_end_timestamp, trip_start_timestamp, SECOND) - mileage.trip_seconds),2)) < 900
)
, fine_tunning_fare AS(
SELECT
  *
FROM time_df AS t
WHERE t.extras < 1000
)
, dist AS (
SELECT
  *
  ,CASE
  WHEN ftf.dropoff_longitude IS NOT NULL 
        OR ftf.dropoff_latitude IS NOT NULL 
        OR ftf.pickup_longitude IS NOT NULL
        OR ftf.pickup_latitude IS NOT NULL
  THEN (ST_DISTANCE(ST_GEOGPOINT(ftf.dropoff_longitude, ftf.dropoff_latitude),
               ST_GEOGPOINT(ftf.pickup_longitude, ftf.pickup_latitude)) * 0.000621371) - ftf.trip_miles 
  ELSE 0
  END AS dist_diff
FROM fine_tunning_fare as ftf
), dist_greater_than_10 AS(
SELECT
  *
FROM dist AS d
WHERE NOT (d.dist_diff > 10)
)
,final_mileage AS(
SELECT
  *
FROM dist_greater_than_10 AS df
WHERE df.trip_miles IS NOT NULL
)
SELECT
  *
FROM final_mileage
)