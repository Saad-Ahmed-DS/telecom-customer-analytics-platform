-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- Step 3: Dimension Tables
-- ============================================================

-- ------------------------------------------------------------
-- 1. dim_customer
-- ------------------------------------------------------------
CREATE TABLE gold.dim_customer (
    customer_key    INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     VARCHAR(20)     NOT NULL UNIQUE,
    gender          VARCHAR(10),
    senior_citizen  BOOLEAN,
    partner         BOOLEAN,
    dependents      BOOLEAN,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  gold.dim_customer                IS 'Customer demographic dimension';
COMMENT ON COLUMN gold.dim_customer.customer_key   IS 'Surrogate primary key';
COMMENT ON COLUMN gold.dim_customer.customer_id    IS 'Business key from source system';

-- ------------------------------------------------------------
-- 2. dim_plan
-- ------------------------------------------------------------
CREATE TABLE gold.dim_plan (
    plan_key            INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    phone_service       VARCHAR(10),
    multiple_lines      VARCHAR(30),
    internet_service    VARCHAR(30),
    online_security     VARCHAR(30),
    online_backup       VARCHAR(30),
    device_protection   VARCHAR(30),
    tech_support        VARCHAR(30),
    streaming_tv        VARCHAR(30),
    streaming_movies    VARCHAR(30),
    contract            VARCHAR(20),
    paperless_billing   BOOLEAN,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gold.dim_plan IS 'Subscription and service plan dimension';

-- ------------------------------------------------------------
-- 3. dim_city
-- ------------------------------------------------------------
CREATE TABLE gold.dim_city (
    city_key    INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city        VARCHAR(100)    NOT NULL,
    province    VARCHAR(100),
    latitude    NUMERIC(9,6),
    longitude   NUMERIC(9,6),
    population  BIGINT,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gold.dim_city IS 'Geographic city dimension';

-- ------------------------------------------------------------
-- 4. dim_date
-- ------------------------------------------------------------
CREATE TABLE gold.dim_date (
    date_key    INTEGER         PRIMARY KEY,
    full_date   DATE            NOT NULL UNIQUE,
    day         SMALLINT        NOT NULL,
    day_name    VARCHAR(10)     NOT NULL,
    week        SMALLINT        NOT NULL,
    month       SMALLINT        NOT NULL,
    month_name  VARCHAR(10)     NOT NULL,
    quarter     SMALLINT        NOT NULL,
    year        SMALLINT        NOT NULL,
    is_weekend  BOOLEAN         NOT NULL DEFAULT FALSE,
    is_holiday  BOOLEAN         NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE gold.dim_date IS 'Calendar date dimension — generated programmatically';

-- ------------------------------------------------------------
-- 5. dim_tower
-- ------------------------------------------------------------
CREATE TABLE gold.dim_tower (
    tower_key       INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mcc             SMALLINT        NOT NULL,
    network_code    SMALLINT        NOT NULL,
    area_code       INTEGER         NOT NULL,
    cell_id         INTEGER         NOT NULL,
    radio           VARCHAR(10),
    latitude        NUMERIC(9,6),
    longitude       NUMERIC(9,6),
    coverage_range  INTEGER,
    sample_count    INTEGER,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (mcc, network_code, area_code, cell_id)
);

COMMENT ON TABLE gold.dim_tower IS 'Network tower infrastructure dimension — source OpenCellID';