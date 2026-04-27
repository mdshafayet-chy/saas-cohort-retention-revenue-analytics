CREATE VIEW saas_db.account_cohorts AS
SELECT
    account_id,
    DATE_FORMAT(signup_date, '%Y-%m-01')  AS cohort_month,
    signup_date                           AS signup_date
FROM saas_db.accounts;