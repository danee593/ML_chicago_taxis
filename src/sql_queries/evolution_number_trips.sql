WITH trunc_month AS(
  SELECT
    CAST(DATETIME_TRUNC(taxi.trip_start_timestamp, MONTH) AS DATE) AS date_formatted
  FROM `big-data-taxis-416219.taxi.taxi_trips` AS taxi
)
, all_months as(
  SELECT
    DATE_ADD('2013-01-01', INTERVAL num1 MONTH) AS months
  FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF('2023-12-01', '2013-01-01', MONTH))) AS num1
)
, grouped_month AS(
  SELECT
    tm.date_formatted
    ,COUNT(*) AS number_of_trips_month
  FROM trunc_month AS tm
  GROUP BY tm.date_formatted
)
SELECT
  am.months
  ,CASE
  WHEN gm.number_of_trips_month IS NULL THEN 0
  ELSE gm.number_of_trips_month
  END AS number_of_trips
FROM grouped_month as gm
  RIGHT JOIN all_months AS am
    ON gm.date_formatted = am.months
ORDER BY am.months;