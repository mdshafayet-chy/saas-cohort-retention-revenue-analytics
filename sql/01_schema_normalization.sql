use saasdbm;

SET SQL_SAFE_UPDATES = 0;

-- Fix accounts.signup_date
UPDATE accounts SET signup_date = STR_TO_DATE(signup_date, '%Y-%m-%d');
ALTER TABLE accounts MODIFY COLUMN signup_date DATE;

-- Fix account_month_mrr.month  
UPDATE account_month_mrr SET month = STR_TO_DATE(month, '%Y-%m-%d');
ALTER TABLE account_month_mrr MODIFY COLUMN month DATE;

-- Fix account_month_mrr.is_active (proper CASE)
UPDATE account_month_mrr 
SET is_active = CASE WHEN is_active = 'True' THEN 1 ELSE 0 END;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE account_month_mrr MODIFY COLUMN is_active TINYINT(1);



-- Verify
-- DESCRIBE accounts;
-- DESCRIBE account_month_mrr;

