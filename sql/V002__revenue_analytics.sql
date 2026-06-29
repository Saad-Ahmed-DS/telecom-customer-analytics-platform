-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Revenue Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Total Revenue
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(monthly_charge), 2)  AS total_monthly_revenue,
    ROUND(SUM(total_charge), 2)    AS total_accumulated_revenue,
    ROUND(AVG(monthly_charge), 2)  AS avg_monthly_charge
FROM gold.fact_customer_snapshot;

-- ------------------------------------------------------------
-- 2. Revenue by Contract Type
-- ------------------------------------------------------------
SELECT
    dp.contract,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2) AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2) AS avg_monthly_charge
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.contract
ORDER BY total_monthly_revenue DESC;

-- ------------------------------------------------------------
-- 3. Revenue by Internet Service
-- ------------------------------------------------------------
SELECT
    dp.internet_service,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2) AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2) AS avg_monthly_charge
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.internet_service
ORDER BY total_monthly_revenue DESC;

-- ------------------------------------------------------------
-- 4. Revenue Category Distribution
-- ------------------------------------------------------------
SELECT
    revenue_category,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(SUM(monthly_charge), 2)                      AS total_revenue,
    ROUND(AVG(monthly_charge), 2)                      AS avg_charge
FROM gold.fact_customer_snapshot
GROUP BY revenue_category
ORDER BY avg_charge DESC;

-- ------------------------------------------------------------
-- 5. Revenue by Customer Segment
-- ------------------------------------------------------------
SELECT
    customer_segment,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(monthly_charge), 2)     AS total_monthly_revenue,
    ROUND(AVG(monthly_charge), 2)     AS avg_monthly_charge,
    ROUND(SUM(total_charge), 2)       AS total_accumulated_revenue
FROM gold.fact_customer_snapshot
GROUP BY customer_segment
ORDER BY total_monthly_revenue DESC;

-- ------------------------------------------------------------
-- 6. Revenue by Gender
-- ------------------------------------------------------------
SELECT
    dc.gender,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2) AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2) AS avg_monthly_charge
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
GROUP BY dc.gender
ORDER BY total_monthly_revenue DESC;

-- ------------------------------------------------------------
-- 7. Monthly Revenue Trend
-- ------------------------------------------------------------
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2) AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2) AS avg_monthly_charge
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_date dd ON fcs.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- ------------------------------------------------------------
-- 8. Revenue by Payment Method
-- ------------------------------------------------------------
SELECT
    fp.payment_method,
    COUNT(*)                          AS total_payments,
    ROUND(SUM(fp.payment_amount), 2)  AS total_revenue,
    ROUND(AVG(fp.payment_amount), 2)  AS avg_payment
FROM gold.fact_payment fp
GROUP BY fp.payment_method
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 9. CLTV Distribution by Revenue Category
-- ------------------------------------------------------------
SELECT
    revenue_category,
    ROUND(MIN(cltv), 2)  AS min_cltv,
    ROUND(AVG(cltv), 2)  AS avg_cltv,
    ROUND(MAX(cltv), 2)  AS max_cltv,
    ROUND(SUM(cltv), 2)  AS total_cltv
FROM gold.fact_customer_snapshot
GROUP BY revenue_category
ORDER BY avg_cltv DESC;

-- ------------------------------------------------------------
-- 10. Top 10 Revenue Generating Customers
-- ------------------------------------------------------------
SELECT
    dc.customer_id,
    fcs.tenure_months,
    fcs.monthly_charge,
    fcs.total_charge,
    fcs.cltv,
    fcs.revenue_category,
    fcs.customer_segment
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
ORDER BY fcs.total_charge DESC
LIMIT 10;