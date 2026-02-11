-- Ensuring that the data has been loaded correctly by counting the number of rows in each table

SELECT 'crm_customers' AS table_name, COUNT(*) AS row_count
FROM raw.crm_customers
UNION
SELECT 'crm_products' AS table_name, COUNT(*) AS row_count
FROM raw.crm_products
UNION
SELECT 'crm_sales' AS table_name, COUNT(*) AS row_count
FROM raw.crm_sales
UNION
SELECT 'erp_customers' AS table_name, COUNT(*) AS row_count
FROM raw.erp_customers
UNION
SELECT 'erp_locations' AS table_name, COUNT(*) AS row_count
FROM raw.erp_locations
UNION
SELECT 'erp_product_categories' AS table_name, COUNT(*) AS row_count
FROM raw.erp_product_categories;



-- Ensuring that the data has been loaded correctly by counting the number of columns in each table

SELECT table_name, COUNT(*) AS column_count FROM information_schema.columns
WHERE table_schema = 'raw' AND (table_name LIKE 'crm_%' OR table_name LIKE 'erp_%')
GROUP BY table_name
ORDER BY table_name;


-- Ensuring that the data has been loaded correctly by checking data types of columns in each table

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'raw' AND (table_name LIKE 'crm_%' OR table_name LIKE 'erp_%')
ORDER BY table_name, column_name;
-- All data purposely ingested as text to avoid issues during the load
-- Data types will be changed later when relational tables are created
