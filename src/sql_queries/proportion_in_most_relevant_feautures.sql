/*

This SQL query analyzes a taxi dataset to understand the proportion of trips with tips, categorized by various attributes such as payment type, pickup and dropoff areas, and trip timestamps. It encodes tips into a binary format, extracts and concatenates area information, and calculates averages and counts across multiple groupings. The query is designed to provide insights into the taxi service usage patterns and behaviors, facilitating data-driven decision-making.

Key Features:
- Encodes tips into a binary format for analysis.
- Extracts and concatenates pickup and dropoff areas for route identification.
- Calculates the average proportion of trips with tips, grouped by various attributes.
- Handles missing values in area information and trip timestamps.
- Utilizes GROUPING SETS for multiple levels of aggregation, including an overall summary.
- Orders the results by the number of observations, highlighting the most common groupings.

This query is structured to enhance readability and maintainability, adhering to SQL best practices such as selecting specific columns over using "SELECT *", and organizing complex queries with Common Table Expressions (CTEs) [Source 1][Source 2][Source 3].
*/

WITH cte AS(
  SELECT
    CASE WHEN t.tips > 0 THEN 1 ELSE 0 END AS tips_encoded -- encode trip to binary (dummy)
    ,t.payment_type -- 1st grouping set does not have nulls
    ,COALESCE(ap.area,"Unknown") AS pickup_community_area -- the area in words obtained from chicago_area_code table
    ,COALESCE(ad.area,"Unknown") AS dropoff_community_area -- the area in words obtained from chicago_area_code table
    ,CAST(EXTRACT(YEAR FROM t.trip_start_timestamp) AS STRING) AS trip_start_year -- converted to string otherwise coalesce will fail
    ,CAST(EXTRACT(HOUR FROM t.trip_start_timestamp) AS STRING) AS trip_start_hour
    ,CAST(EXTRACT(YEAR FROM t.trip_end_timestamp) AS STRING) AS trip_end_year
    ,CAST(EXTRACT(HOUR FROM t.trip_end_timestamp) AS STRING) AS trip_end_hour
    ,CONCAT(COALESCE(ap.area,"Unknown")," - ",COALESCE(ad.area,"Unknown")) AS route -- route is the concatenation of the start and end area.
  FROM `big-data-taxis-416219.taxi.taxi_cleaned` AS t 
    LEFT JOIN `big-data-taxis-416219.taxi.chicago_area_code` AS ad -- left join needed to keep the nulls in the cleaned taxi dataset
      ON t.dropoff_community_area = ad.code
    LEFT JOIN `big-data-taxis-416219.taxi.chicago_area_code` AS ap -- two joins because there are two columns that are encoded
      ON t.pickup_community_area = ap.code
)
SELECT
 ROUND(AVG(c.tips_encoded),2) AS proportion -- takes the proportion of 1s (tipped trips)
 ,COUNT(*) AS no_observations_class -- number of observations in each grouping set, useful for knowing what's the best predictor.
 ,COALESCE(c.payment_type,"exclude") AS payment_type -- from here on grouping sets.
 ,COALESCE(c.pickup_community_area,"exclude") AS pickup_community_area
 ,COALESCE(c.dropoff_community_area,"exclude") AS dropoff_community_area
 ,COALESCE(c.trip_start_year, "exclude") AS trip_start_year
 ,COALESCE(c.trip_start_hour, "exclude") AS trip_start_hour
 ,COALESCE(c.trip_end_year, "exclude") AS trip_end_year
 ,COALESCE(c.trip_end_hour, "exclude") AS trip_end_hour
 ,COALESCE(c.route, "exclude") AS route
FROM cte AS c
GROUP BY GROUPING SETS ((c.payment_type), (c.pickup_community_area), (c.dropoff_community_area), -- grouping sets, easier to plot this way
                        (c.trip_start_year), (c.trip_start_hour), (c.trip_end_year), (c.trip_end_hour),
                        (c.route), ()); -- () empty set to get the proportion of tipped trips to the overall trips.

