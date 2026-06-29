-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Churn Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall Churn Rate
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END)                    AS churned_customers,
    ROUND(SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct
FROM gold.fact_customer_snapshot;

-- ------------------------------------------------------------
-- 2. Churn by Contract Type
-- ------------------------------------------------------------
SELECT
    dp.contract,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)                AS churned,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.contract
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 3. Churn by Internet Service
-- ------------------------------------------------------------
SELECT
    dp.internet_service,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)                AS churned,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.internet_service
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 4. Churn by Gender
-- ------------------------------------------------------------
SELECT
    dc.gender,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)                AS churned,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
GROUP BY dc.gender
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 5. Churn by Senior Citizen
-- ------------------------------------------------------------
SELECT
    CASE WHEN dc.senior_citizen THEN 'Senior' ELSE 'Non-Senior' END AS citizen_type,
    COUNT(*)                                                          AS total_customers,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)                  AS churned,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                              AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
GROUP BY dc.senior_citizen
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 6. Churn by Customer Segment
-- ------------------------------------------------------------
SELECT
    customer_segment,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END)                    AS churned,
    ROUND(SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct,
    ROUND(AVG(tenure_months), 2)                                    AS avg_tenure
FROM gold.fact_customer_snapshot
GROUP BY customer_segment
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 7. Churn by Revenue Category
-- ------------------------------------------------------------
SELECT
    revenue_category,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END)                    AS churned,
    ROUND(SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct,
    ROUND(AVG(monthly_charge), 2)                                   AS avg_monthly_charge
FROM gold.fact_customer_snapshot
GROUP BY revenue_category
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 8. Average Churn Score by Contract Type
-- ------------------------------------------------------------
SELECT
    dp.contract,
    ROUND(AVG(fcs.churn_score), 2)  AS avg_churn_score,
    ROUND(MIN(fcs.churn_score), 2)  AS min_churn_score,
    ROUND(MAX(fcs.churn_score), 2)  AS max_churn_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.contract
ORDER BY avg_churn_score DESC;

-- ------------------------------------------------------------
-- 9. Top 10 Churn Reasons
-- ------------------------------------------------------------
SELECT
    churn_reason,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.fact_customer_snapshot
WHERE churn_flag = TRUE
  AND churn_reason IS NOT NULL
GROUP BY churn_reason
ORDER BY total_customers DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 10. High Risk Customers (Churn Score > 70)
-- ------------------------------------------------------------
SELECT
    dc.customer_id,
    fcs.tenure_months,
    fcs.churn_score,
    fcs.monthly_charge,
    fcs.cltv,
    fcs.customer_segment,
    dp.contract
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
JOIN gold.dim_plan dp     ON fcs.plan_key     = dp.plan_key
WHERE fcs.churn_score > 70
  AND fcs.churn_flag  = FALSE
ORDER BY fcs.churn_score DESC
LIMIT 10;