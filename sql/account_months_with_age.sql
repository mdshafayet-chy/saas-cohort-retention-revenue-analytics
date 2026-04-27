CREATE VIEW saas_db.account_months_with_age AS
SELECT
    m.account_id,
    a.cohort_month,
    m.month,
    PERIOD_DIFF(
        DATE_FORMAT(m.month, '%Y%m'),
        DATE_FORMAT(a.cohort_month, '%Y%m')
    )                                AS months_since_cohort
FROM saas_db.account_month_mrr  m
JOIN saas_db.account_cohorts    a  ON a.account_id = m.account_id;