-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Payment Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall Payment Summary
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS total_payments,
    ROUND(SUM(payment_amount), 2)       AS total_revenue,
    ROUND(AVG(payment_amount), 2)       AS avg_payment,
    ROUND(MIN(payment_amount), 2)       AS min_payment,
    ROUND(MAX(payment_amount), 2)       AS max_payment
FROM gold.fact_payment;

-- ------------------------------------------------------------
-- 2. Payment Status Distribution
-- ------------------------------------------------------------
SELECT
    payment_status,
    COUNT(*)                                           AS total_payments,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(SUM(payment_amount), 2)                      AS total_amount
FROM gold.fact_payment
GROUP BY payment_status
ORDER BY total_payments DESC;

-- ------------------------------------------------------------
-- 3. Revenue by Payment Method
-- ------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*)                            AS total_payments,
    ROUND(SUM(payment_amount), 2)       AS total_revenue,
    ROUND(AVG(payment_amount), 2)       AS avg_payment,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.fact_payment
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 4. Late Payment Analysis
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN late_payment_days = 0  THEN 'On Time'
        WHEN late_payment_days <= 7 THEN 'Late 1-7 Days'
        WHEN late_payment_days <= 15 THEN 'Late 8-15 Days'
        ELSE 'Late 15+ Days'
    END                                                AS late_category,
    COUNT(*)                                           AS total_payments,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(payment_amount), 2)                      AS avg_payment
FROM gold.fact_payment
GROUP BY
    CASE
        WHEN late_payment_days = 0  THEN 'On Time'
        WHEN late_payment_days <= 7 THEN 'Late 1-7 Days'
        WHEN late_payment_days <= 15 THEN 'Late 8-15 Days'
        ELSE 'Late 15+ Days'
    END
ORDER BY total_payments DESC;

-- ------------------------------------------------------------
-- 5. Payment Status by Customer Segment
-- ------------------------------------------------------------
SELECT
    fcs.customer_segment,
    fp.payment_status,
    COUNT(*)                            AS total_payments,
    ROUND(SUM(fp.payment_amount), 2)    AS total_revenue
FROM gold.fact_payment fp
JOIN gold.fact_customer_snapshot fcs ON fp.customer_key = fcs.customer_key
GROUP BY fcs.customer_segment, fp.payment_status
ORDER BY fcs.customer_segment, total_payments DESC;

-- ------------------------------------------------------------
-- 6. Monthly Payment Trend
-- ------------------------------------------------------------
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(*)                            AS total_payments,
    ROUND(SUM(fp.payment_amount), 2)    AS total_revenue,
    ROUND(AVG(fp.payment_amount), 2)    AS avg_payment
FROM gold.fact_payment fp
JOIN gold.dim_date dd ON fp.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- ------------------------------------------------------------
-- 7. Failed Payments by Customer Segment
-- ------------------------------------------------------------
SELECT
    fcs.customer_segment,
    COUNT(*)                                           AS failed_payments,
    ROUND(SUM(fp.payment_amount), 2)                   AS lost_revenue,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM gold.fact_payment fp
JOIN gold.fact_customer_snapshot fcs ON fp.customer_key = fcs.customer_key
WHERE fp.payment_status = 'Failed'
GROUP BY fcs.customer_segment
ORDER BY failed_payments DESC;

-- ------------------------------------------------------------
-- 8. Average Late Payment Days by Payment Method
-- ------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*)                                AS total_payments,
    SUM(CASE WHEN late_payment_days > 0
             THEN 1 ELSE 0 END)             AS late_payments,
    ROUND(AVG(CASE WHEN late_payment_days > 0
             THEN late_payment_days END), 2) AS avg_late_days
FROM gold.fact_payment
GROUP BY payment_method
ORDER BY avg_late_days DESC;

-- ------------------------------------------------------------
-- 9. Top 10 Customers by Payment Amount
-- ------------------------------------------------------------
SELECT
    dc.customer_id,
    fcs.customer_segment,
    fcs.revenue_category,
    ROUND(SUM(fp.payment_amount), 2)    AS total_paid,
    COUNT(fp.payment_key)               AS total_payments,
    fp.payment_status
FROM gold.fact_payment fp
JOIN gold.dim_customer dc           ON fp.customer_key  = dc.customer_key
JOIN gold.fact_customer_snapshot fcs ON fp.customer_key = fcs.customer_key
GROUP BY dc.customer_id, fcs.customer_segment,
         fcs.revenue_category, fp.payment_status
ORDER BY total_paid DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 10. Payment Collection Rate
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(CASE WHEN payment_status = 'Paid'
              THEN payment_amount ELSE 0 END), 2)       AS collected_revenue,
    ROUND(SUM(CASE WHEN payment_status = 'Pending'
              THEN payment_amount ELSE 0 END), 2)       AS pending_revenue,
    ROUND(SUM(CASE WHEN payment_status = 'Failed'
              THEN payment_amount ELSE 0 END), 2)       AS failed_revenue,
    ROUND(SUM(CASE WHEN payment_status = 'Paid'
              THEN payment_amount ELSE 0 END) * 100.0
          / SUM(payment_amount), 2)                     AS collection_rate_pct
FROM gold.fact_payment;