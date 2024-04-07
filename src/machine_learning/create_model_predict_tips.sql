CREATE MODEL `big-data-taxis-416219.taxi.model_predict_tips`
OPTIONS(MODEL_TYPE='BOOSTED_TREE_CLASSIFIER',
        BOOSTER_TYPE = 'GBTREE',
        NUM_PARALLEL_TREE = 1,
        MAX_ITERATIONS = 20,
        TREE_METHOD = 'AUTO',
        EARLY_STOP = TRUE,
        SUBSAMPLE = 0.85,
        INPUT_LABEL_COLS = ['label']) AS

SELECT
  CAST(CASE WHEN t.tips > 0 THEN TRUE ELSE FALSE END AS STRING) AS label
  ,EXTRACT(YEAR FROM t.trip_start_timestamp) AS trip_start_year
  ,EXTRACT(HOUR FROM t.trip_start_timestamp) AS trip_start_hour
  ,EXTRACT(YEAR FROM t.trip_end_timestamp) AS trip_end_year
  ,EXTRACT(HOUR FROM t.trip_end_timestamp) AS trip_end_hour
  ,t.trip_seconds
  ,t.trip_miles
  ,ap.area AS pickup_community_area
  ,ad.area AS dropoff_community_area
  ,LN(t.fare) AS ln_fare
  ,COALESCE(t.tolls,0) AS tolls
  ,t.extras
  ,t.payment_type
FROM `big-data-taxis-416219.taxi.taxi_cleaned` AS t
  LEFT JOIN `big-data-taxis-416219.taxi.chicago_area_code` AS ap
    ON t.pickup_community_area = ap.code
  LEFT JOIN `big-data-taxis-416219.taxi.chicago_area_code` AS ad
    ON t.dropoff_community_area = ad.code;