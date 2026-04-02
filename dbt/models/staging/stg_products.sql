-- This takes the raw table and cleans it up
WITH raw_data AS (
    SELECT * FROM {{ source('raw', 'raw_products') }}
)

SELECT 
    -- 1. Clean up column names
    CAST("Index" AS INTEGER) AS product_index,
    CAST("Internal ID" AS INTEGER) AS internal_id,
    "Name", 
    "Description", 
    "Brand", 
    "Category", 
    CAST("Price" AS DECIMAL(10, 2)) AS price,
    "Currency", 
    CAST("Stock" AS INTEGER) AS stock,
    "EAN", 
    "Color", 
    "Size", 
    "Availability"
	

FROM raw_data
WHERE "Index" IS NOT NULL