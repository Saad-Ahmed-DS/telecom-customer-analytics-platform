-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- SQL Analytics: Support Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall Support Summary
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                    AS total_tickets,
    ROUND(AVG(resolution_time_hours), 2)        AS avg_resolution_hours,
    ROUND(MIN(resolution_time_hours), 2)        AS min_resolution_hours,
    ROUND(MAX(resolution_time_hours), 2)        AS max_resolution_hours,
    SUM(CASE WHEN ticket_status = 'Open'
             THEN 1 ELSE 0 END)                 AS open_tickets,
    SUM(CASE WHEN ticket_status = 'Closed'
             THEN 1 ELSE 0 END)                 AS closed_tickets
FROM gold.fact_support;

-- ------------------------------------------------------------
-- 2. Tickets by Issue Type
-- ------------------------------------------------------------
SELECT
    issue_type,
    COUNT(*)                                           AS total_tickets,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(resolution_time_hours), 2)               AS avg_resolution_hours
FROM gold.fact_support
GROUP BY issue_type
ORDER BY total_tickets DESC;

-- ------------------------------------------------------------
-- 3. Tickets by Priority
-- ------------------------------------------------------------
SELECT
    priority,
    COUNT(*)                                           AS total_tickets,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(resolution_time_hours), 2)               AS avg_resolution_hours,
    SUM(CASE WHEN ticket_status = 'Open'
             THEN 1 ELSE 0 END)                        AS open_tickets
FROM gold.fact_support
GROUP BY priority
ORDER BY total_tickets DESC;

-- ------------------------------------------------------------
-- 4. Ticket Status Distribution
-- ------------------------------------------------------------
SELECT
    ticket_status,
    COUNT(*)                                           AS total_tickets,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(resolution_time_hours), 2)               AS avg_resolution_hours
FROM gold.fact_support
GROUP BY ticket_status
ORDER BY total_tickets DESC;

-- ------------------------------------------------------------
-- 5. Support Tickets by Customer Segment
-- ------------------------------------------------------------
SELECT
    fcs.customer_segment,
    COUNT(fs.ticket_key)                               AS total_tickets,
    ROUND(AVG(fs.resolution_time_hours), 2)            AS avg_resolution_hours,
    SUM(CASE WHEN fs.ticket_status = 'Open'
             THEN 1 ELSE 0 END)                        AS open_tickets,
    ROUND(COUNT(fs.ticket_key) * 100.0
          / SUM(COUNT(fs.ticket_key)) OVER(), 2)       AS percentage
FROM gold.fact_support fs
JOIN gold.fact_customer_snapshot fcs ON fs.customer_key = fcs.customer_key
GROUP BY fcs.customer_segment
ORDER BY total_tickets DESC;

-- ------------------------------------------------------------
-- 6. Critical Tickets Analysis
-- ------------------------------------------------------------
SELECT
    issue_type,
    COUNT(*)                                AS total_critical,
    ROUND(AVG(resolution_time_hours), 2)    AS avg_resolution_hours,
    SUM(CASE WHEN ticket_status = 'Open'
             THEN 1 ELSE 0 END)             AS open_critical
FROM gold.fact_support
WHERE priority = 'Critical'
GROUP BY issue_type
ORDER BY total_critical DESC;

-- ------------------------------------------------------------
-- 7. Monthly Ticket Trend
-- ------------------------------------------------------------
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(*)                                AS total_tickets,
    ROUND(AVG(fs.resolution_time_hours), 2) AS avg_resolution_hours,
    SUM(CASE WHEN fs.ticket_status = 'Open'
             THEN 1 ELSE 0 END)             AS open_tickets
FROM gold.fact_support fs
JOIN gold.dim_date dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- ------------------------------------------------------------
-- 8. Churn vs Support Ticket Correlation
-- ------------------------------------------------------------
SELECT
    CASE WHEN fcs.churn_flag THEN 'Churned' ELSE 'Active' END AS customer_status,
    COUNT(fs.ticket_key)                                       AS total_tickets,
    ROUND(AVG(fs.resolution_time_hours), 2)                    AS avg_resolution_hours,
    ROUND(AVG(fcs.churn_score), 2)                             AS avg_churn_score
FROM gold.fact_customer_snapshot fcs
LEFT JOIN gold.fact_support fs ON fcs.customer_key = fs.customer_key
GROUP BY fcs.churn_flag
ORDER BY total_tickets DESC;

-- ------------------------------------------------------------
-- 9. Resolution Time by Priority
-- ------------------------------------------------------------
SELECT
    priority,
    ROUND(AVG(resolution_time_hours), 2)    AS avg_resolution_hours,
    ROUND(MIN(resolution_time_hours), 2)    AS min_resolution_hours,
    ROUND(MAX(resolution_time_hours), 2)    AS max_resolution_hours,
    COUNT(*)                                AS total_tickets
FROM gold.fact_support
GROUP BY priority
ORDER BY avg_resolution_hours DESC;

-- ------------------------------------------------------------
-- 10. Top 10 Customers with Most Support Tickets
-- ------------------------------------------------------------
SELECT
    dc.customer_id,
    fcs.customer_segment,
    fcs.churn_flag,
    COUNT(fs.ticket_key)                    AS total_tickets,
    ROUND(AVG(fs.resolution_time_hours), 2) AS avg_resolution_hours,
    SUM(CASE WHEN fs.ticket_status = 'Open'
             THEN 1 ELSE 0 END)             AS open_tickets
FROM gold.fact_support fs
JOIN gold.dim_customer dc            ON fs.customer_key  = dc.customer_key
JOIN gold.fact_customer_snapshot fcs ON fs.customer_key  = fcs.customer_key
GROUP BY dc.customer_id, fcs.customer_segment, fcs.churn_flag
ORDER BY total_tickets DESC
LIMIT 10;