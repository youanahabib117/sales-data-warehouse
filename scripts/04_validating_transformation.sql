-- Ensuring that the data has been transformed correctly by counting the number of columns in each table

SELECT table_name, COUNT(*) AS column_count FROM information_schema.columns
WHERE table_schema = 'raw' AND table_name LIKE 'stg_%'
GROUP BY table_name
ORDER BY table_name;


-- Ensuring that the data has been transformed correctly by checking data types of columns in each table

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'raw' AND table_name LIKE 'stg_%'
ORDER BY table_name;