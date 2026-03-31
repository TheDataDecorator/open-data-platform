-- Application Metadata (The "Brains")
CREATE DATABASE airflow_db;
CREATE DATABASE superset_db;
CREATE DATABASE nifi_db; -- For future-proofing

-- The Actual Data (The "Goods")
CREATE DATABASE warehouse;

-- Permissions
GRANT ALL PRIVILEGES ON DATABASE airflow_db TO data;
GRANT ALL PRIVILEGES ON DATABASE superset_db TO data;
GRANT ALL PRIVILEGES ON DATABASE nifi_db TO data;
GRANT ALL PRIVILEGES ON DATABASE warehouse TO data;

-- Connect to the warehouse database
\c warehouse;

-- 1. RAW: Where NiFi drops the data (unfiltered, messy)
CREATE SCHEMA IF NOT EXISTS raw;

-- 2. STAGING: Where dbt cleans the data (standardized types/names)
CREATE SCHEMA IF NOT EXISTS staging;

-- 3. ANALYTICS: Where your final tables live (What Superset sees)
CREATE SCHEMA IF NOT EXISTS analytics;

-- 4. Set Permissions (The "Safety" Layer)
GRANT ALL PRIVILEGES ON SCHEMA raw TO data;
GRANT ALL PRIVILEGES ON SCHEMA staging TO data;
GRANT ALL PRIVILEGES ON SCHEMA analytics TO data;