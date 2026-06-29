-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Network Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall Network Performance Summary
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(signal_strength), 2)      AS avg_signal_strength,
    ROUND(AVG(latency_ms), 2)           AS avg_latency_ms,
    ROUND(AVG(packet_loss_percent), 2)  AS avg_packet_loss_pct,
    ROUND(AVG(downtime_minutes), 2)     AS avg_downtime_minutes,
    ROUND(AVG(network_score), 2)        AS avg_network_score
FROM gold.fact_customer_snapshot;

-- ------------------------------------------------------------
-- 2. Network Score Distribution
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN network_score >= 75 THEN 'Excellent'
        WHEN network_score >= 50 THEN 'Good'
        WHEN network_score >= 25 THEN 'Fair'
        ELSE 'Poor'
    END                                                        AS network_quality,
    COUNT(*)                                                   AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)         AS percentage,
    ROUND(AVG(network_score), 2)                               AS avg_network_score
FROM gold.fact_customer_snapshot
GROUP BY
    CASE
        WHEN network_score >= 75 THEN 'Excellent'
        WHEN network_score >= 50 THEN 'Good'
        WHEN network_score >= 25 THEN 'Fair'
        ELSE 'Poor'
    END
ORDER BY avg_network_score DESC;

-- ------------------------------------------------------------
-- 3. Network Performance by Radio Technology
-- ------------------------------------------------------------
SELECT
    dt.radio,
    COUNT(*)                                    AS total_customers,
    ROUND(AVG(fcs.signal_strength), 2)          AS avg_signal_strength,
    ROUND(AVG(fcs.latency_ms), 2)               AS avg_latency_ms,
    ROUND(AVG(fcs.packet_loss_percent), 2)      AS avg_packet_loss_pct,
    ROUND(AVG(fcs.network_score), 2)            AS avg_network_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_tower dt ON fcs.tower_key = dt.tower_key
GROUP BY dt.radio
ORDER BY avg_network_score DESC;

-- ------------------------------------------------------------
-- 4. Network Performance vs Churn
-- ------------------------------------------------------------
SELECT
    CASE WHEN churn_flag THEN 'Churned' ELSE 'Active' END   AS customer_status,
    ROUND(AVG(signal_strength), 2)                          AS avg_signal_strength,
    ROUND(AVG(latency_ms), 2)                               AS avg_latency_ms,
    ROUND(AVG(packet_loss_percent), 2)                      AS avg_packet_loss_pct,
    ROUND(AVG(downtime_minutes), 2)                         AS avg_downtime_minutes,
    ROUND(AVG(network_score), 2)                            AS avg_network_score
FROM gold.fact_customer_snapshot
GROUP BY churn_flag
ORDER BY avg_network_score DESC;

-- ------------------------------------------------------------
-- 5. Top 10 Towers by Customer Count
-- ------------------------------------------------------------
SELECT
    dt.tower_key,
    dt.radio,
    dt.coverage_range,
    COUNT(*)                        AS total_customers,
    ROUND(AVG(fcs.network_score), 2) AS avg_network_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_tower dt ON fcs.tower_key = dt.tower_key
GROUP BY dt.tower_key, dt.radio, dt.coverage_range
ORDER BY total_customers DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 6. Data Usage by Internet Service
-- ------------------------------------------------------------
SELECT
    dp.internet_service,
    COUNT(*)                            AS total_customers,
    ROUND(AVG(fcs.data_usage_gb), 2)   AS avg_data_usage_gb,
    ROUND(SUM(fcs.data_usage_gb), 2)   AS total_data_usage_gb,
    ROUND(MAX(fcs.data_usage_gb), 2)   AS max_data_usage_gb
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_plan dp ON fcs.plan_key = dp.plan_key
GROUP BY dp.internet_service
ORDER BY avg_data_usage_gb DESC;

-- ------------------------------------------------------------
-- 7. Usage Segment Distribution
-- ------------------------------------------------------------
SELECT
    usage_segment,
    COUNT(*)                                           AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(data_usage_gb), 2)                       AS avg_data_usage_gb,
    ROUND(AVG(voice_minutes), 2)                       AS avg_voice_minutes,
    ROUND(AVG(monthly_charge), 2)                      AS avg_monthly_charge
FROM gold.fact_customer_snapshot
GROUP BY usage_segment
ORDER BY avg_data_usage_gb DESC;

-- ------------------------------------------------------------
-- 8. Voice and SMS Usage Summary
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(voice_minutes), 2)        AS avg_voice_minutes,
    ROUND(SUM(voice_minutes), 2)        AS total_voice_minutes,
    ROUND(AVG(sms_count), 2)            AS avg_sms_count,
    ROUND(SUM(sms_count), 2)            AS total_sms_count,
    ROUND(AVG(roaming_minutes), 2)      AS avg_roaming_minutes,
    ROUND(AVG(international_minutes), 2) AS avg_international_minutes
FROM gold.fact_customer_snapshot;

-- ------------------------------------------------------------
-- 9. Network Score vs Churn Score Correlation
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN network_score >= 75 THEN 'Excellent'
        WHEN network_score >= 50 THEN 'Good'
        WHEN network_score >= 25 THEN 'Fair'
        ELSE 'Poor'
    END                                 AS network_quality,
    ROUND(AVG(churn_score), 2)          AS avg_churn_score,
    ROUND(AVG(monthly_charge), 2)       AS avg_monthly_charge,
    COUNT(*)                            AS total_customers
FROM gold.fact_customer_snapshot
GROUP BY
    CASE
        WHEN network_score >= 75 THEN 'Excellent'
        WHEN network_score >= 50 THEN 'Good'
        WHEN network_score >= 25 THEN 'Fair'
        ELSE 'Poor'
    END
ORDER BY avg_churn_score DESC;

-- ------------------------------------------------------------
-- 10. Tower Coverage Range Distribution
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN coverage_range >= 5000 THEN 'Wide (5km+)'
        WHEN coverage_range >= 2000 THEN 'Medium (2-5km)'
        WHEN coverage_range >= 1000 THEN 'Standard (1-2km)'
        ELSE 'Small (<1km)'
    END                                                        AS coverage_type,
    COUNT(*)                                                   AS total_towers,
    ROUND(AVG(coverage_range), 2)                              AS avg_coverage_range,
    ROUND(AVG(sample_count), 2)                                AS avg_samples
FROM gold.dim_tower
GROUP BY
    CASE
        WHEN coverage_range >= 5000 THEN 'Wide (5km+)'
        WHEN coverage_range >= 2000 THEN 'Medium (2-5km)'
        WHEN coverage_range >= 1000 THEN 'Standard (1-2km)'
        ELSE 'Small (<1km)'
    END
ORDER BY avg_coverage_range DESC;