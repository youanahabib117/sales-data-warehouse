-- Exploring the structure of the analytics schema and associated tables

-- Retrieving tables in the analytics schema
SELECT table_schema, table_name, table_type
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'analytics';

-- Retrieving all columns for sales_fact table
SELECT table_schema, table_name, column_name, ordinal_position, data_type
FROM INFORMATION_SCHEMA.columns
WHERE table_name = 'sales_fact';

-- Retrieving all columns for products_dim table
SELECT table_schema, table_name, column_name, ordinal_position, data_type
FROM INFORMATION_SCHEMA.columns
WHERE table_name = 'products_dim';

-- Retrieving all columns for customers_dim table
SELECT table_schema, table_name, column_name, ordinal_position, data_type
FROM INFORMATION_SCHEMA.columns
WHERE table_name = 'customers_dim';




-- Exploring table dimensions

-- Product key, category, subcategory, name (products_dim)
SELECT DISTINCT prd_key, cat, subcat, prd_name
FROM analytics.products_dim
GROUP BY prd_key, cat, subcat, prd_name
ORDER BY cat, subcat, prd_name;

-- Marital Status (customers_dim)
SELECT DISTINCT cust_marital_status
FROM analytics.customers_dim;

-- Country (customers_dim)
SELECT DISTINCT cust_country
FROM analytics.customers_dim;




-- Exploring table measures

-- KPIs
SELECT 
    'Total Sales' AS "Measure", SUM(sales_total) AS "Value"
FROM analytics.sales_fact
UNION ALL
SELECT
    'Total Orders' AS "Measure", COUNT(DISTINCT order_num) AS "Value"
FROM analytics.sales_fact
UNION ALL
SELECT
    'Average Order Total' AS "Measure", ROUND(AVG(sales_total), 0) AS "Value"
FROM (SELECT order_num, SUM(sales_total) AS sales_total
      FROM analytics.sales_fact
      GROUP BY order_num)
UNION ALL
SELECT
    'Total Products Sold' AS "Measure", SUM(quantity) AS "Value"
FROM analytics.sales_fact
UNION ALL
SELECT
    'Total Number of Products' AS "Measure", COUNT(DISTINCT prd_key) AS "Value"
FROM analytics.products_dim
UNION ALL
SELECT
    'Total Customers' AS "Measure", COUNT(DISTINCT cust_id) AS "Value"
FROM analytics.customers_dim;
