SELECT 'fact_customer_snapshot' AS table_name, COUNT(*) AS rows FROM gold.fact_customer_snapshot
UNION ALL
SELECT 'fact_payment',  COUNT(*) FROM gold.fact_payment
UNION ALL
SELECT 'fact_support',  COUNT(*) FROM gold.fact_support;