-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Geographic Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Customer Distribution by Province
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.province
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 2. Revenue by Province
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2) AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2) AS avg_monthly_charge,
    ROUND(AVG(fcs.cltv), 2)           AS avg_cltv
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.province
ORDER BY total_monthly_revenue DESC;

-- ------------------------------------------------------------
-- 3. Churn Rate by Province
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)                AS churned,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                            AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.province
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 4. Top 10 Cities by Customer Count
-- ------------------------------------------------------------
SELECT
    dc_city.city,
    dc_city.province,
    COUNT(*)                          AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2) AS total_monthly_revenue
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.city, dc_city.province
ORDER BY total_customers DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 5. Network Quality by Province
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    ROUND(AVG(fcs.signal_strength), 2)     AS avg_signal_strength,
    ROUND(AVG(fcs.latency_ms), 2)          AS avg_latency_ms,
    ROUND(AVG(fcs.network_score), 2)       AS avg_network_score,
    COUNT(*)                               AS total_customers
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.province
ORDER BY avg_network_score DESC;

-- ------------------------------------------------------------
-- 6. Support Tickets by Province
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    COUNT(*)                                           AS total_tickets,
    ROUND(AVG(fs.resolution_time_hours), 2)            AS avg_resolution_hours,
    SUM(CASE WHEN fs.ticket_status = 'Open'
             THEN 1 ELSE 0 END)                        AS open_tickets,
    SUM(CASE WHEN fs.ticket_status = 'Closed'
             THEN 1 ELSE 0 END)                        AS closed_tickets
FROM gold.fact_support fs
JOIN gold.dim_city dc_city ON fs.city_key = dc_city.city_key
WHERE fs.city_key != -1
GROUP BY dc_city.province
ORDER BY total_tickets DESC;

-- ------------------------------------------------------------
-- 7. Population vs Customer Penetration
-- ------------------------------------------------------------
SELECT
    dc_city.city,
    dc_city.province,
    dc_city.population,
    COUNT(fcs.customer_key)                AS total_customers,
    ROUND(COUNT(fcs.customer_key) * 100.0
          / NULLIF(dc_city.population, 0), 4) AS penetration_pct
FROM gold.dim_city dc_city
LEFT JOIN gold.fact_customer_snapshot fcs ON fcs.city_key = dc_city.city_key
GROUP BY dc_city.city, dc_city.province, dc_city.population
ORDER BY total_customers DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 8. Average CLTV by City
-- ------------------------------------------------------------
SELECT
    dc_city.city,
    dc_city.province,
    COUNT(*)                    AS total_customers,
    ROUND(AVG(fcs.cltv), 2)    AS avg_cltv,
    ROUND(AVG(fcs.churn_score), 2) AS avg_churn_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.city, dc_city.province
ORDER BY avg_cltv DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 9. Tower Distribution by Province
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    COUNT(DISTINCT fcs.tower_key)           AS total_towers,
    ROUND(AVG(dt.coverage_range), 2)        AS avg_coverage_range,
    ROUND(AVG(fcs.network_score), 2)        AS avg_network_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city  dc_city ON fcs.city_key  = dc_city.city_key
JOIN gold.dim_tower dt      ON fcs.tower_key = dt.tower_key
WHERE fcs.city_key != -1
GROUP BY dc_city.province
ORDER BY total_towers DESC;

-- ------------------------------------------------------------
-- 10. High Churn Risk Cities
-- ------------------------------------------------------------
SELECT
    dc_city.city,
    dc_city.province,
    COUNT(*)                                                        AS total_customers,
    ROUND(AVG(fcs.churn_score), 2)                                  AS avg_churn_score,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)                 AS churned_customers,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                             AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.city, dc_city.province
HAVING COUNT(*) > 10
ORDER BY churn_rate_pct DESC
LIMIT 10;


