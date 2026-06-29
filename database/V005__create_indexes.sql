-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- Step 5: Indexes
-- ============================================================

-- ------------------------------------------------------------
-- dim_customer
-- ------------------------------------------------------------
CREATE INDEX idx_dim_customer_customer_id
    ON gold.dim_customer (customer_id);

-- ------------------------------------------------------------
-- dim_city
-- ------------------------------------------------------------
CREATE INDEX idx_dim_city_city
    ON gold.dim_city (city);

-- ------------------------------------------------------------
-- dim_tower
-- ------------------------------------------------------------
CREATE INDEX idx_dim_tower_radio
    ON gold.dim_tower (radio);

-- ------------------------------------------------------------
-- fact_customer_snapshot
-- ------------------------------------------------------------
CREATE INDEX idx_snapshot_customer_key
    ON gold.fact_customer_snapshot (customer_key);

CREATE INDEX idx_snapshot_date_key
    ON gold.fact_customer_snapshot (date_key);

CREATE INDEX idx_snapshot_city_key
    ON gold.fact_customer_snapshot (city_key);

CREATE INDEX idx_snapshot_plan_key
    ON gold.fact_customer_snapshot (plan_key);

CREATE INDEX idx_snapshot_tower_key
    ON gold.fact_customer_snapshot (tower_key);

CREATE INDEX idx_snapshot_churn_flag
    ON gold.fact_customer_snapshot (churn_flag);

-- Composite Indexes
CREATE INDEX idx_snapshot_customer_date
    ON gold.fact_customer_snapshot (customer_key, date_key);

CREATE INDEX idx_snapshot_date_city
    ON gold.fact_customer_snapshot (date_key, city_key);

CREATE INDEX idx_snapshot_city_tower
    ON gold.fact_customer_snapshot (city_key, tower_key);

-- ------------------------------------------------------------
-- fact_payment
-- ------------------------------------------------------------
CREATE INDEX idx_payment_customer_key
    ON gold.fact_payment (customer_key);

CREATE INDEX idx_payment_date_key
    ON gold.fact_payment (date_key);

CREATE INDEX idx_payment_status
    ON gold.fact_payment (payment_status);

-- ------------------------------------------------------------
-- fact_support
-- ------------------------------------------------------------
CREATE INDEX idx_support_customer_key
    ON gold.fact_support (customer_key);

CREATE INDEX idx_support_date_key
    ON gold.fact_support (date_key);

CREATE INDEX idx_support_city_key
    ON gold.fact_support (city_key);

CREATE INDEX idx_support_ticket_status
    ON gold.fact_support (ticket_status);