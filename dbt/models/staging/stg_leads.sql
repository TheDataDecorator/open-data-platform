-- This takes the raw table and cleans it up
WITH raw_data AS (
    SELECT * FROM {{ source('raw', 'raw_leads') }}
)

SELECT 
    -- 1. Clean up column names
    cast("Index" AS INTEGER) AS lead_index,
    "Account Id" AS account_id,
    "Lead Owner", 
    "First Name", 
    "Last Name", 
    "Company", 
    "Phone 1", 
    "Phone 2", 
    "Email 1", 
    "Email 2", 
    "Website", 
    "Source", 
    "Deal Stage", 
    "Notes"


FROM raw_data
WHERE "Index" IS NOT NULL