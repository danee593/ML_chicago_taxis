WITH des_model AS (
    SELECT
        CASE WHEN t.Tips > 0 THEN 1 ELSE 0 END AS label,
        CASE WHEN t.Payment_Type = "Credit Card" THEN 1 ELSE 0 END AS decision_model
    FROM `big-data-taxis-416219.taxi.taxis_2024` AS t
    WHERE t.Fare > 3.25
),
metrics AS (
    SELECT
        CASE WHEN (dm.label = 1 AND dm.decision_model = 1) THEN 1 ELSE 0 END AS true_positives,
        CASE WHEN (dm.label = 0 AND dm.decision_model = 0) THEN 1 ELSE 0 END AS true_negatives,
        CASE WHEN (dm.label = 0 AND dm.decision_model = 1) THEN 1 ELSE 0 END AS false_positives,
        CASE WHEN (dm.label = 1 AND dm.decision_model = 0) THEN 1 ELSE 0 END AS false_negatives
    FROM des_model AS dm
),
accuracy AS (
    SELECT
        SUM(m.true_positives) AS tp,
        SUM(m.true_negatives) AS tn,
        SUM(m.false_positives) AS fp,
        SUM(m.false_negatives) AS fn
    FROM metrics AS m
)
SELECT ROUND((a.tp + a.tn) / (a.tp + a.tn + a.fp + a.fn),2) AS accuracy
FROM accuracy AS a;
