CREATE DATABASE telecom_dw
    WITH
    OWNER      = postgres
    ENCODING   = 'UTF8'
    LC_COLLATE = 'English_Pakistan.1252'
    LC_CTYPE   = 'English_Pakistan.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE telecom_dw IS 
    'Telecom Customer Analytics & Churn Intelligence Platform — Data Warehouse';