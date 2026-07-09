-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Analytical Views
-- Purpose: Pre-built views for Power BI and Machine Learning
-- ============================================================

-- ------------------------------------------------------------
-- 1. Customer 360 View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_customer_360 AS
SELECT
    dc.customer_id,
    dc.gender,
    dc.senior_citizen,
    dc.partner,
    dc.dependents,
    dp.contract,
    dp.internet_service,
    dp.phone_service,
    dp.streaming_tv,
    dp.streaming_movies,
    dp.online_security,
    dp.online_backup,
    dp.device_protection,
    dp.tech_support,
    dp.paperless_billing,
    dcity.city,
    dcity.province,
    fcs.tenure_months,
    fcs.monthly_charge,
    fcs.total_charge,
    fcs.cltv,
    -- churn_score retained here for REFERENCE/SEGMENTATION only
    -- NOT used in ML model — it is IBM's pre-computed propensity score
    fcs.churn_score,
    fcs.churn_flag,
    fcs.churn_reason,
    fcs.revenue_category,
    fcs.usage_segment,
    fcs.customer_segment,
    fcs.data_usage_gb,
    fcs.voice_minutes,
    fcs.sms_count,
    fcs.signal_strength,
    fcs.network_score,
    fcs.latency_ms
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc    ON fcs.customer_key = dc.customer_key
JOIN gold.dim_plan dp        ON fcs.plan_key     = dp.plan_key
JOIN gold.dim_city dcity     ON fcs.city_key     = dcity.city_key
WHERE fcs.customer_key != -1;

-- ------------------------------------------------------------
-- 2. Churn Analysis View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_churn_analysis AS
SELECT
    dc.customer_id,
    dc.gender,
    dc.senior_citizen,
    dc.partner,
    dc.dependents,
    dp.contract,
    dp.internet_service,
    dp.multiple_lines,
    fcs.tenure_months,
    fcs.monthly_charge,
    fcs.total_charge,
    fcs.cltv,
    -- churn_score retained for BI dashboards/segmentation only
    -- confirmed leaky for ML — excluded from vw_ml_features
    fcs.churn_score,
    fcs.churn_flag,
    fcs.churn_reason,
    fcs.customer_segment,
    fcs.revenue_category,
    -- NOTE: network_score is synthetically generated (random inputs)
    -- shown for illustrative purposes only — not real signal
    fcs.network_score,
    fcs.signal_strength,
    fcs.data_usage_gb
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
JOIN gold.dim_plan dp     ON fcs.plan_key     = dp.plan_key
WHERE fcs.customer_key != -1;

-- ------------------------------------------------------------
-- 3. Revenue View
-- NOTE: snapshot dates are derived from customer tenure
-- relative to base_date 2025-01-01 — not real billing history
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_revenue AS
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    dd.quarter,
    dcity.province,
    dcity.city,
    dp.contract,
    dp.internet_service,
    fcs.customer_segment,
    fcs.revenue_category,
    COUNT(*)                            AS total_customers,
    ROUND(SUM(fcs.monthly_charge), 2)   AS total_monthly_revenue,
    ROUND(AVG(fcs.monthly_charge), 2)   AS avg_monthly_charge,
    ROUND(SUM(fcs.total_charge), 2)     AS total_accumulated_revenue,
    ROUND(AVG(fcs.cltv), 2)             AS avg_cltv
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_date dd    ON fcs.date_key  = dd.date_key
JOIN gold.dim_city dcity ON fcs.city_key  = dcity.city_key
JOIN gold.dim_plan dp    ON fcs.plan_key  = dp.plan_key
WHERE fcs.customer_key != -1
GROUP BY
    dd.year, dd.month, dd.month_name, dd.quarter,
    dcity.province, dcity.city,
    dp.contract, dp.internet_service,
    fcs.customer_segment, fcs.revenue_category;

-- ------------------------------------------------------------
-- 4. Network Performance View
-- NOTE: signal_strength, latency_ms, packet_loss_percent,
-- downtime_minutes are synthetically generated (random values)
-- network_score is derived from these synthetic inputs
-- Geographic data is randomly assigned — not real customer locations
-- All network visuals are ILLUSTRATIVE ONLY
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_network_performance AS
SELECT
    dt.radio,
    dt.coverage_range,
    dcity.province,
    dcity.city,
    COUNT(*)                                    AS total_customers,
    ROUND(AVG(fcs.signal_strength), 2)          AS avg_signal_strength,
    ROUND(AVG(fcs.latency_ms), 2)               AS avg_latency_ms,
    ROUND(AVG(fcs.packet_loss_percent), 2)      AS avg_packet_loss_pct,
    ROUND(AVG(fcs.downtime_minutes), 2)         AS avg_downtime_minutes,
    ROUND(AVG(fcs.network_score), 2)            AS avg_network_score,
    -- churn_score kept here for BI reference only — not ML input
    ROUND(AVG(fcs.churn_score), 2)              AS avg_churn_score
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_tower dt   ON fcs.tower_key = dt.tower_key
JOIN gold.dim_city dcity ON fcs.city_key  = dcity.city_key
WHERE fcs.customer_key != -1
GROUP BY
    dt.radio, dt.coverage_range,
    dcity.province, dcity.city;

-- ------------------------------------------------------------
-- 5. Payment Summary View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_payment_summary AS
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    dd.quarter,
    fp.payment_method,
    fp.payment_status,
    fcs.customer_segment,
    fcs.revenue_category,
    COUNT(*)                            AS total_payments,
    ROUND(SUM(fp.payment_amount), 2)    AS total_revenue,
    ROUND(AVG(fp.payment_amount), 2)    AS avg_payment,
    ROUND(AVG(fp.late_payment_days), 2) AS avg_late_days
FROM gold.fact_payment fp
JOIN gold.dim_date dd                ON fp.date_key     = dd.date_key
JOIN gold.fact_customer_snapshot fcs ON fp.customer_key = fcs.customer_key
WHERE fp.customer_key != -1
GROUP BY
    dd.year, dd.month, dd.month_name, dd.quarter,
    fp.payment_method, fp.payment_status,
    fcs.customer_segment, fcs.revenue_category;

-- ------------------------------------------------------------
-- 6. Support Summary View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_support_summary AS
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    dd.quarter,
    dcity.province,
    fs.issue_type,
    fs.priority,
    fs.ticket_status,
    fcs.customer_segment,
    COUNT(*)                                AS total_tickets,
    ROUND(AVG(fs.resolution_time_hours), 2) AS avg_resolution_hours
FROM gold.fact_support fs
JOIN gold.dim_date dd                ON fs.date_key     = dd.date_key
JOIN gold.dim_city dcity             ON fs.city_key     = dcity.city_key
JOIN gold.fact_customer_snapshot fcs ON fs.customer_key = fcs.customer_key
WHERE fs.customer_key != -1
GROUP BY
    dd.year, dd.month, dd.month_name, dd.quarter,
    dcity.province, fs.issue_type,
    fs.priority, fs.ticket_status,
    fcs.customer_segment;

-- ------------------------------------------------------------
-- 7. ML Feature View (for Machine Learning)
-- FIXES APPLIED:
--   - churn_score REMOVED (data leakage — IBM pre-computed propensity score)
--   - cltv RETAINED (weak correlation -0.127, acceptable risk, documented)
--   - network/usage metrics RETAINED (synthetic but structurally valid)
--   - churn_flag is the ONLY target variable
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW gold.vw_ml_features AS
SELECT
    dc.customer_id,
    dc.gender,
    CAST(dc.senior_citizen AS INTEGER)      AS senior_citizen,
    CAST(dc.partner AS INTEGER)             AS partner,
    CAST(dc.dependents AS INTEGER)          AS dependents,
    dp.contract,
    dp.internet_service,
    dp.phone_service,
    dp.multiple_lines,
    dp.online_security,
    dp.online_backup,
    dp.device_protection,
    dp.tech_support,
    dp.streaming_tv,
    dp.streaming_movies,
    CAST(dp.paperless_billing AS INTEGER)   AS paperless_billing,
    fcs.tenure_months,
    fcs.monthly_charge,
    fcs.total_charge,
    fcs.cltv,
    -- churn_score INTENTIONALLY EXCLUDED
    -- Reason: IBM pre-computed propensity score derived from actual churn outcome
    -- Including it causes data leakage (correlation with churn_flag = 0.665)
    -- ROC AUC inflated from ~0.82 to 0.98 when included
    fcs.data_usage_gb,
    fcs.voice_minutes,
    fcs.sms_count,
    fcs.roaming_minutes,
    fcs.international_minutes,
    fcs.signal_strength,
    fcs.latency_ms,
    fcs.packet_loss_percent,
    fcs.downtime_minutes,
    fcs.network_score,
    fcs.revenue_category,
    fcs.usage_segment,
    fcs.customer_segment,
    CAST(fcs.churn_flag AS INTEGER)         AS churn_flag
FROM gold.fact_customer_snapshot fcs
JOIN gold.dim_customer dc ON fcs.customer_key = dc.customer_key
JOIN gold.dim_plan dp     ON fcs.plan_key     = dp.plan_key
WHERE fcs.customer_key != -1;

-- ------------------------------------------------------------
-- Verify Views
-- ------------------------------------------------------------
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'gold'
ORDER BY table_name;


