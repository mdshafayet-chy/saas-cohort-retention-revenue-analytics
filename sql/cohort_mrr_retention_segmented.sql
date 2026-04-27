CREATE OR REPLACE VIEW `saasdbm`.`cohort_mrr_retention_segmented` AS

WITH

-- STEP 1: Aggregate first (GROUP BY only, no window function)
grouped AS (
    SELECT
        ama.cohort_month,
        ama.months_since_cohort,
        a.initial_plan,
        a.acquisition_channel,
        SUM(m.mrr)             AS cohort_mrr,
        SUM(m.mrr_expansion)   AS mrr_expansion,
        SUM(m.mrr_churn)       AS mrr_churn,
        SUM(m.mrr_contraction) AS mrr_contraction
    FROM `saasdbm`.`account_months_with_age` ama
    JOIN `saasdbm`.`account_month_mrr`       m  ON ama.account_id = m.account_id
                                               AND ama.month      = m.month
    JOIN `saasdbm`.`accounts`                a  ON ama.account_id = a.account_id
    GROUP BY
        ama.cohort_month, ama.months_since_cohort,
        a.initial_plan,   a.acquisition_channel
),

-- STEP 2: Now apply window function on the aggregated rows (no raw columns left)
mrr_by_segment AS (
    SELECT
        *,
        MAX(CASE WHEN months_since_cohort = 0 THEN cohort_mrr ELSE 0 END)
            OVER (PARTITION BY cohort_month, initial_plan, acquisition_channel)
            AS start_mrr
    FROM grouped
)

SELECT
    s.cohort_month,
    s.months_since_cohort,
    s.initial_plan,
    s.acquisition_channel,
    ROUND(s.start_mrr,  2) AS start_mrr,
    ROUND(s.cohort_mrr, 2) AS cohort_mrr,
    ROUND(GREATEST(s.start_mrr - s.mrr_churn - s.mrr_contraction,                   0) / NULLIF(s.start_mrr, 0), 4) AS grr,
    ROUND(GREATEST(s.start_mrr - s.mrr_churn - s.mrr_contraction + s.mrr_expansion, 0) / NULLIF(s.start_mrr, 0), 4) AS nrr,
    lr.logo_retention_rate_pct AS logo_retention_rate
FROM mrr_by_segment s
LEFT JOIN `saasdbm`.`cohort_logo_retention` lr
    ON  s.cohort_month        = lr.cohort_month
    AND s.months_since_cohort = lr.months_since_cohort
WHERE s.start_mrr > 0
ORDER BY s.cohort_month DESC, s.initial_plan, s.acquisition_channel, s.months_since_cohort;