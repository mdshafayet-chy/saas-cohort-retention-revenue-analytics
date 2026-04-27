CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `cohort_logo_retention` AS
    SELECT 
        `ama`.`cohort_month` AS `cohort_month`,
        `ama`.`months_since_cohort` AS `months_since_cohort`,
        `cohort_size`.`accounts_in_cohort` AS `accounts_in_cohort`,
        COUNT(DISTINCT (CASE
                WHEN (COALESCE(`amm`.`is_active`, 1) = 1) THEN `ama`.`account_id`
            END)) AS `active_accounts`,
        ROUND(((COUNT(DISTINCT (CASE
                        WHEN (COALESCE(`amm`.`is_active`, 1) = 1) THEN `ama`.`account_id`
                    END)) * 100.0) / `cohort_size`.`accounts_in_cohort`),
                2) AS `logo_retention_rate_pct`
    FROM
        ((`account_months_with_age` `ama`
        JOIN (SELECT 
            `account_months_with_age`.`cohort_month` AS `cohort_month`,
                COUNT(DISTINCT `account_months_with_age`.`account_id`) AS `accounts_in_cohort`
        FROM
            `account_months_with_age`
        WHERE
            (`account_months_with_age`.`months_since_cohort` = 0)
        GROUP BY `account_months_with_age`.`cohort_month`) `cohort_size` ON ((`ama`.`cohort_month` = `cohort_size`.`cohort_month`)))
        LEFT JOIN `account_month_mrr` `amm` ON (((`ama`.`account_id` = `amm`.`account_id`)
            AND (`ama`.`month` = `amm`.`month`))))
    WHERE
        (`ama`.`months_since_cohort` <= 12)
    GROUP BY `ama`.`cohort_month` , `ama`.`months_since_cohort` , `cohort_size`.`accounts_in_cohort`
    ORDER BY `ama`.`cohort_month` , `ama`.`months_since_cohort`