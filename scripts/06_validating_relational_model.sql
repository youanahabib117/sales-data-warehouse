-- Checking data types
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'relational'
ORDER BY table_name;


-- Checking each table's primary key
SELECT tc.table_name, kc.column_name AS primary_key_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kc
ON tc.constraint_name = kc.constraint_name
AND tc.table_schema = kc.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
AND tc.table_schema = 'relational';


-- Checking foreign key relationships between tables
SELECT tc.table_name, kc.column_name AS fk_column, cu.table_name AS referenced_table, cu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kc
ON tc.constraint_name = kc.constraint_name
AND tc.table_schema = kc.table_schema
JOIN information_schema.constraint_column_usage cu
ON cu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'relational';