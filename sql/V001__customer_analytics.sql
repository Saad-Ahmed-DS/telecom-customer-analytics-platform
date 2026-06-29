-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Customer Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Total Customer Count
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_customers
FROM gold.dim_customer;

-- ------------------------------------------------------------
-- 2. Gender Distribution
-- ------------------------------------------------------------
SELECT
    gender,
    COUNT(*)                                    AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.dim_customer
GROUP BY gender
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 3. Senior Citizen Distribution
-- ------------------------------------------------------------
SELECT
    CASE WHEN senior_citizen THEN 'Senior' ELSE 'Non-Senior' END AS citizen_type,
    COUNT(*)                                                       AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)            AS percentage
FROM gold.dim_customer
GROUP BY senior_citizen
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 4. Partner and Dependents Distribution
-- ------------------------------------------------------------
SELECT
    CASE WHEN partner    THEN 'Has Partner'    ELSE 'No Partner'    END AS partner_status,
    CASE WHEN dependents THEN 'Has Dependents' ELSE 'No Dependents' END AS dependent_status,
    COUNT(*) AS total_customers
FROM gold.dim_customer
GROUP BY partner, dependents
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 5. Customer Segment Distribution
-- ------------------------------------------------------------
SELECT
    customer_segment,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.fact_customer_snapshot
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 6. Average Tenure by Gender
-- ------------------------------------------------------------
SELECT
    dc.gender,
    ROUND(AVG(fcs.tenure_months), 2) AS avg_tenure_months
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
GROUP BY dc.gender
ORDER BY avg_tenure_months DESC;

-- ------------------------------------------------------------
-- 7. Customer Distribution by Contract Type
-- ------------------------------------------------------------
SELECT
    dp.contract,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.contract
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 8. New vs Loyal vs VIP Customers
-- ------------------------------------------------------------
SELECT
    customer_segment,
    COUNT(*)                                           AS total_customers,
    ROUND(AVG(tenure_months), 2)                       AS avg_tenure,
    ROUND(AVG(monthly_charge), 2)                      AS avg_monthly_charge,
    ROUND(AVG(cltv), 2)                                AS avg_cltv
FROM gold.fact_customer_snapshot
GROUP BY customer_segment
ORDER BY avg_tenure DESC;

-- ------------------------------------------------------------
-- 9. Top 10 Customers by CLTV
-- ------------------------------------------------------------
SELECT
    dc.customer_id,
    dc.gender,
    fcs.tenure_months,
    fcs.monthly_charge,
    fcs.cltv,
    fcs.customer_segment
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
ORDER BY fcs.cltv DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 10. Customer Count by Internet Service Type
-- ------------------------------------------------------------
SELECT
    dp.internet_service,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(fcs.monthly_charge), 2)                  AS avg_monthly_charge
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.internet_service
ORDER BY total_customers DESC;