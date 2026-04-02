-- This takes the raw table and cleans it up
WITH raw_data AS (
    SELECT * FROM {{ source('raw', 'raw_people') }}
)

SELECT 
    -- 1. Clean up column names
    cast("Index" AS INTEGER) AS people_index,
    "User Id" AS user_id,
	"First Name", 
    "Last Name", 
    "Sex", 
    "Email", 
    "Phone", 
    TO_TIMESTAMP("Date of birth", 'YYYY/MM/DD') AS user_dob,
     "Job Title"

FROM raw_data
WHERE "Index" IS NOT NULL