-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- Step 6: Unknown Records
-- Purpose: Default records for failed FK lookups during ETL
--          Uses -1 as the unknown key per key strategy doc
-- ============================================================

-- ------------------------------------------------------------
-- dim_customer — Unknown Record
-- ------------------------------------------------------------
INSERT INTO gold.dim_customer
    (customer_key, customer_id, gender, senior_citizen, partner, dependents)
OVERRIDING SYSTEM VALUE
VALUES
    (-1, 'UNKNOWN', 'Unknown', NULL, NULL, NULL);

-- ------------------------------------------------------------
-- dim_plan — Unknown Record
-- ------------------------------------------------------------
INSERT INTO gold.dim_plan
    (plan_key, phone_service, multiple_lines, internet_service,
     online_security, online_backup, device_protection,
     tech_support, streaming_tv, streaming_movies,
     contract, paperless_billing)
OVERRIDING SYSTEM VALUE
VALUES
    (-1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown',
     'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', NULL);

-- ------------------------------------------------------------
-- dim_city — Unknown Record
-- ------------------------------------------------------------
INSERT INTO gold.dim_city
    (city_key, city, province, latitude, longitude, population)
OVERRIDING SYSTEM VALUE
VALUES
    (-1, 'Unknown', 'Unknown', NULL, NULL, NULL);

-- ------------------------------------------------------------
-- dim_date — Unknown Record
-- ------------------------------------------------------------
INSERT INTO gold.dim_date
    (date_key, full_date, day, day_name, week, month,
     month_name, quarter, year, is_weekend, is_holiday)
VALUES
    (-1, '1900-01-01', 1, 'Unknown', 1, 1,
     'Unknown', 1, 1900, FALSE, FALSE);

-- ------------------------------------------------------------
-- dim_tower — Unknown Record
-- ------------------------------------------------------------
INSERT INTO gold.dim_tower
    (tower_key, mcc, network_code, area_code, cell_id,
     radio, latitude, longitude, coverage_range, sample_count)
OVERRIDING SYSTEM VALUE
VALUES
    (-1, -1, -1, -1, -1, 'Unknown', NULL, NULL, NULL, NULL);