CREATE OR REPLACE VIEW cohort_mrr_retention AS

WITH monthly_cohort_data AS (
    SELECT 
        am.cohort_month,
        am.months_since_cohort,
        SUM(m.mrr)             AS cohort_mrr,
        SUM(m.mrr_expansion)   AS mrr_expansion,
        SUM(m.mrr_churn)       AS mrr_churn,        
        SUM(m.mrr_contraction) AS mrr_contraction   
    FROM account_months_with_age am
    JOIN account_month_mrr m 
      ON am.account_id = m.account_id 
     AND am.month = m.month
    WHERE am.months_since_cohort >= 0
    GROUP BY am.cohort_month, am.months_since_cohort
),

cohort_starting_mrr AS (
    SELECT 
        cohort_month,
        months_since_cohort,
        cohort_mrr,
        mrr_expansion,
        mrr_churn,
        mrr_contraction,
        MAX(CASE WHEN months_since_cohort = 0 THEN cohort_mrr ELSE 0 END) 
            OVER (PARTITION BY cohort_month) AS start_mrr
    FROM monthly_cohort_data
)

SELECT 
    cohort_month,
    months_since_cohort,
    ROUND(start_mrr, 2)    AS start_mrr,
    ROUND(cohort_mrr, 2)   AS cohort_mrr,

    -- GRR: losses only (churn + contraction), no expansion, floored at 0
    ROUND(
        GREATEST(start_mrr - mrr_churn - mrr_contraction, 0) / NULLIF(start_mrr, 0), 4
    ) AS grr,

    -- NRR: losses + gains, can exceed 1.0
    ROUND(
        GREATEST(start_mrr - mrr_churn - mrr_contraction + mrr_expansion, 0) / NULLIF(start_mrr, 0), 4
    ) AS nrr

FROM cohort_starting_mrr
WHERE start_mrr > 0
ORDER BY cohort_month DESC, months_since_cohort ASC;