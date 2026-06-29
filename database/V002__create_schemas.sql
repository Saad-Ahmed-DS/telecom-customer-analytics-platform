-- ============================================================
-- Telecom Customer Analytics & Churn Intelligence Platform
-- Step 2: Schema Creation
-- ============================================================

-- Bronze Layer: Raw data as-is from source files
CREATE SCHEMA IF NOT EXISTS bronze
    AUTHORIZATION postgres;

-- Silver Layer: Cleaned and validated data
CREATE SCHEMA IF NOT EXISTS silver
    AUTHORIZATION postgres;

-- Gold Layer: Dimensional warehouse tables
CREATE SCHEMA IF NOT EXISTS gold
    AUTHORIZATION postgres;

-- Comments
COMMENT ON SCHEMA bronze IS 'Raw source data — no transformations applied';
COMMENT ON SCHEMA silver IS 'Cleaned and validated data — ready for transformation';
COMMENT ON SCHEMA gold   IS 'Dimensional warehouse — dimensions and fact tables';