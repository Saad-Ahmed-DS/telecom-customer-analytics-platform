-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Executive KPIs
-- ============================================================

-- ------------------------------------------------------------
-- 1. Executive Dashboard Summary
-- ------------------------------------------------------------
SELECT
    COUNT(DISTINCT fcs.customer_key)            AS total_customers,
    SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN fcs.churn_flag THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                AS churn_rate_pct,
    ROUND(SUM(fcs.monthly_charge), 2)           AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2)           AS avg_monthly_charge,
    ROUND(AVG(fcs.cltv), 2)                     AS avg_cltv,
    ROUND(AVG(fcs.tenure_months), 2)            AS avg_tenure_months,
    ROUND(AVG(fcs.churn_score), 2)              AS avg_churn_score,
    ROUND(AVG(fcs.network_score), 2)            AS avg_network_score
FROM gold.fact_customer_snapshot fcs
WHERE fcs.customer_key != -1;

-- ------------------------------------------------------------
-- 2. Revenue at Risk (High Churn Score Customers)
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS high_risk_customers,
    ROUND(SUM(monthly_charge), 2)       AS revenue_at_risk,
    ROUND(AVG(cltv), 2)                 AS avg_cltv_at_risk,
    ROUND(AVG(churn_score), 2)          AS avg_churn_score
FROM gold.fact_customer_snapshot
WHERE churn_score > 70
  AND churn_flag = FALSE;

-- ------------------------------------------------------------
-- 3. Month over Month Revenue
-- ------------------------------------------------------------
SELECT
    dd.year,
    dd.month_name,
    ROUND(SUM(fcs.monthly_charge), 2)   AS monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2)   AS avg_charge,
    COUNT(*)                            AS total_customers
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_date dd ON fcs.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- ------------------------------------------------------------
-- 4. Customer Lifetime Value Summary
-- ------------------------------------------------------------
SELECT
    customer_segment,
    COUNT(*)                        AS total_customers,
    ROUND(AVG(cltv), 2)             AS avg_cltv,
    ROUND(SUM(cltv), 2)             AS total_cltv,
    ROUND(AVG(tenure_months), 2)    AS avg_tenure,
    ROUND(AVG(churn_score), 2)      AS avg_churn_score
FROM gold.fact_customer_snapshot
GROUP BY customer_segment
ORDER BY avg_cltv DESC;

-- ------------------------------------------------------------
-- 5. Payment Collection KPI
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                AS total_payments,
    ROUND(SUM(payment_amount), 2)                           AS total_billed,
    ROUND(SUM(CASE WHEN payment_status = 'Paid'
              THEN payment_amount ELSE 0 END), 2)           AS total_collected,
    ROUND(SUM(CASE WHEN payment_status = 'Failed'
              THEN payment_amount ELSE 0 END), 2)           AS total_failed,
    ROUND(SUM(CASE WHEN payment_status = 'Paid'
              THEN payment_amount ELSE 0 END) * 100.0
          / SUM(payment_amount), 2)                         AS collection_rate_pct
FROM gold.fact_payment;

-- ------------------------------------------------------------
-- 6. Network Health KPI
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(network_score), 2)            AS avg_network_score,
    ROUND(AVG(signal_strength), 2)          AS avg_signal_strength,
    ROUND(AVG(latency_ms), 2)               AS avg_latency_ms,
    ROUND(AVG(packet_loss_percent), 2)      AS avg_packet_loss_pct,
    ROUND(AVG(downtime_minutes), 2)         AS avg_downtime_minutes,
    SUM(CASE WHEN network_score >= 75
             THEN 1 ELSE 0 END)             AS excellent_network_customers,
    SUM(CASE WHEN network_score < 25
             THEN 1 ELSE 0 END)             AS poor_network_customers
FROM gold.fact_customer_snapshot;

-- ------------------------------------------------------------
-- 7. Support Efficiency KPI
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                AS total_tickets,
    SUM(CASE WHEN ticket_status = 'Closed'
             THEN 1 ELSE 0 END)                             AS resolved_tickets,
    SUM(CASE WHEN ticket_status = 'Open'
             THEN 1 ELSE 0 END)                             AS open_tickets,
    ROUND(SUM(CASE WHEN ticket_status = 'Closed'
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)    AS resolution_rate_pct,
    ROUND(AVG(resolution_time_hours), 2)                    AS avg_resolution_hours
FROM gold.fact_support;

-- ------------------------------------------------------------
-- 8. Churn Prevention Opportunity
-- ------------------------------------------------------------
SELECT
    dp.contract,
    COUNT(*)                                                AS high_risk_customers,
    ROUND(SUM(fcs.monthly_charge), 2)                       AS revenue_at_risk,
    ROUND(AVG(fcs.cltv), 2)                                 AS avg_cltv,
    ROUND(AVG(fcs.churn_score), 2)                          AS avg_churn_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
WHERE fcs.churn_score > 70
  AND fcs.churn_flag = FALSE
GROUP BY dp.contract
ORDER BY revenue_at_risk DESC;

-- ------------------------------------------------------------
-- 9. Top Performing Provinces
-- ------------------------------------------------------------
SELECT
    dc_city.province,
    COUNT(*)                            AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2)   AS total_revenue,
    ROUND(AVG(fcs.cltv), 2)             AS avg_cltv,
    ROUND(SUM(CASE WHEN fcs.churn_flag
              THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                AS churn_rate_pct
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_city dc_city ON fcs.city_key = dc_city.city_key
WHERE fcs.city_key != -1
GROUP BY dc_city.province
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 10. Full Executive Scorecard
-- ------------------------------------------------------------
SELECT
    'Total Customers'       AS kpi, CAST(COUNT(*) AS TEXT) AS value
FROM gold.fact_customer_snapshot
UNION ALL
SELECT
    'Churn Rate %',
    CAST(ROUND(SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END)
         * 100.0 / COUNT(*), 2) AS TEXT)
FROM gold.fact_customer_snapshot
UNION ALL
SELECT
    'Total Monthly Revenue',
    CAST(ROUND(SUM(monthly_charge), 2) AS TEXT)
FROM gold.fact_customer_snapshot
UNION ALL
SELECT
    'Avg CLTV',
    CAST(ROUND(AVG(cltv), 2) AS TEXT)
FROM gold.fact_customer_snapshot
UNION ALL
SELECT
    'Avg Network Score',
    CAST(ROUND(AVG(network_score), 2) AS TEXT)
FROM gold.fact_customer_snapshot
UNION ALL
SELECT
    'Total Support Tickets',
    CAST(COUNT(*) AS TEXT)
FROM gold.fact_support
UNION ALL
SELECT
    'Payment Collection Rate %',
    CAST(ROUND(SUM(CASE WHEN payment_status = 'Paid'
                   THEN payment_amount ELSE 0 END) * 100.0
         / SUM(payment_amount), 2) AS TEXT)
FROM gold.fact_payment;