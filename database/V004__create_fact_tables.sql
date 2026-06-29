-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- Step 4: Fact Tables
-- ============================================================

-- ------------------------------------------------------------
-- 1. fact_customer_snapshot
-- ------------------------------------------------------------
CREATE TABLE gold.fact_customer_snapshot (
    snapshot_key            INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Foreign Keys
    customer_key            INTEGER         NOT NULL,
    date_key                INTEGER         NOT NULL,
    city_key                INTEGER         NOT NULL,
    plan_key                INTEGER         NOT NULL,
    tower_key               INTEGER         NOT NULL,

    -- Customer Metrics
    tenure_months           SMALLINT,
    churn_flag              BOOLEAN,
    churn_score             SMALLINT,
    cltv                    INTEGER,
    churn_reason            VARCHAR(100),

    -- Billing Metrics
    monthly_charge          NUMERIC(10,2),
    total_charge            NUMERIC(10,2),

    -- Usage Metrics (Generated)
    data_usage_gb           NUMERIC(8,2),
    voice_minutes           INTEGER,
    sms_count               INTEGER,
    roaming_minutes         INTEGER,
    international_minutes   INTEGER,

    -- Network Metrics (Generated)
    signal_strength         NUMERIC(5,2),
    latency_ms              NUMERIC(8,2),
    packet_loss_percent     NUMERIC(5,2),
    downtime_minutes        INTEGER,
    network_score           NUMERIC(5,2),

    -- Derived Segments
    revenue_category        VARCHAR(10),
    usage_segment           VARCHAR(10),
    customer_segment        VARCHAR(10),

    -- Audit
    created_at              TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints
    CONSTRAINT fk_snapshot_customer FOREIGN KEY (customer_key) REFERENCES gold.dim_customer (customer_key),
    CONSTRAINT fk_snapshot_date     FOREIGN KEY (date_key)     REFERENCES gold.dim_date     (date_key),
    CONSTRAINT fk_snapshot_city     FOREIGN KEY (city_key)     REFERENCES gold.dim_city     (city_key),
    CONSTRAINT fk_snapshot_plan     FOREIGN KEY (plan_key)     REFERENCES gold.dim_plan     (plan_key),
    CONSTRAINT fk_snapshot_tower    FOREIGN KEY (tower_key)    REFERENCES gold.dim_tower    (tower_key)
);

COMMENT ON TABLE gold.fact_customer_snapshot IS 'Central periodic snapshot fact — one row per customer per month';

-- ------------------------------------------------------------
-- 2. fact_payment
-- ------------------------------------------------------------
CREATE TABLE gold.fact_payment (
    payment_key         INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Foreign Keys
    customer_key        INTEGER         NOT NULL,
    date_key            INTEGER         NOT NULL,

    -- Measures
    payment_amount      NUMERIC(10,2),
    payment_method      VARCHAR(30),
    payment_status      VARCHAR(20),
    late_payment_days   SMALLINT,

    -- Audit
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints
    CONSTRAINT fk_payment_customer  FOREIGN KEY (customer_key) REFERENCES gold.dim_customer (customer_key),
    CONSTRAINT fk_payment_date      FOREIGN KEY (date_key)     REFERENCES gold.dim_date     (date_key)
);

COMMENT ON TABLE gold.fact_payment IS 'Payment transaction fact — one row per payment';

-- ------------------------------------------------------------
-- 3. fact_support
-- ------------------------------------------------------------
CREATE TABLE gold.fact_support (
    ticket_key              INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Foreign Keys
    customer_key            INTEGER         NOT NULL,
    date_key                INTEGER         NOT NULL,
    city_key                INTEGER         NOT NULL,

    -- Measures
    issue_type              VARCHAR(50),
    priority                VARCHAR(20),
    resolution_time_hours   NUMERIC(8,2),
    ticket_status           VARCHAR(20),

    -- Audit
    created_at              TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints
    CONSTRAINT fk_support_customer  FOREIGN KEY (customer_key) REFERENCES gold.dim_customer (customer_key),
    CONSTRAINT fk_support_date      FOREIGN KEY (date_key)     REFERENCES gold.dim_date     (date_key),
    CONSTRAINT fk_support_city      FOREIGN KEY (city_key)     REFERENCES gold.dim_city     (city_key)
);

COMMENT ON TABLE gold.fact_support IS 'Support ticket fact — one row per support ticket';