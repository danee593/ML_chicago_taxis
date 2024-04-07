SELECT *
FROM ML.EVALUATE(MODEL `big-data-taxis-416219.taxi.model_10_percent`,
  (
    SELECT
        CAST(CASE WHEN t.Tips > 0 THEN TRUE ELSE FALSE END AS STRING) AS label
        ,EXTRACT(YEAR FROM TIMESTAMP_MICROS(CAST(t.Trip_Start_Timestamp/1000 AS INT64))) AS trip_start_year
        ,EXTRACT(HOUR FROM TIMESTAMP_MICROS(CAST(t.Trip_Start_Timestamp/1000 AS INT64))) AS trip_start_hour
        ,EXTRACT(YEAR FROM TIMESTAMP_MICROS(CAST(t.Trip_End_Timestamp/1000 AS INT64))) AS trip_end_year
        ,EXTRACT(HOUR FROM TIMESTAMP_MICROS(CAST(t.Trip_End_Timestamp/1000 AS INT64))) AS trip_end_hour
        ,CAST(t.Trip_Seconds AS INT64) AS trip_seconds
        ,t.Trip_Miles AS trip_miles
        ,ap.area AS pickup_community_area
        ,ad.area AS dropoff_community_area
        ,LN(t.Fare) AS ln_fare
        ,COALESCE(t.Tolls,0) AS tolls
        ,t.Extras
        ,t.Payment_Type
    FROM `big-data-taxis-416219.taxi.taxis_2024` AS t
        LEFT JOIN `big-data-taxis-416219.taxi.chicago_area_code` AS ap
          ON t.Pickup_Community_Area = ap.code
        LEFT JOIN `big-data-taxis-416219.taxi.chicago_area_code` AS ad
          ON t.Dropoff_Community_Area = ad.code
    WHERE t.Fare > 3.25
  )
);