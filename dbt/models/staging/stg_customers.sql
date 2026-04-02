-- This takes the raw table and cleans it up
WITH raw_data AS (
    SELECT * FROM {{ source('raw', 'raw_customers') }}
)

SELECT 
    -- 1. Clean up column names
    cast("Index" AS INTEGER) AS customer_index,
    "Customer Id" AS customer_id,
    TO_TIMESTAMP("Subscription Date", 'YYYY/MM/DD') AS subscription_date,
	"First Name", 
	"Last Name", 
	"Company", 
	"City", 
	"Country", 
	"Phone 1", 
	"Phone 2", 
	"Email", 
	"Website"

FROM raw_data
WHERE "Index" IS NOT NULL