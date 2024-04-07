/*2.	In Chicago, which months historically see the highest volume of taxi trips?*/


  SELECT
  CASE EXTRACT(MONTH FROM trip_start_timestamp)
    WHEN 1 THEN 'January'
    WHEN 2 THEN 'February'
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
  END AS month_name,
  COUNT(*) AS trip_count
FROM
  `big-data-taxis-416219.taxi.taxi_cleaned`
GROUP BY
  month_name
ORDER BY
  trip_count DESC;
