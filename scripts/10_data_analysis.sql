-- Looking at the big picture of the data:

-- 1. Total customers by country
SELECT 
    cust_country AS "Country",
    COUNT(DISTINCT cust_id) AS "Total Customers"
FROM analytics.customers_dim
GROUP BY cust_country
ORDER BY "Total Customers" DESC;

-- 2. Total customers by gender
SELECT
    cust_gender AS "Gender",
    COUNT(DISTINCT cust_id) AS "Total Customers"
FROM analytics.customers_dim
GROUP BY cust_gender
ORDER BY "Total Customers" DESC;

-- 3. Total Products by category
SELECT
    cat AS "Category",
    COUNT(DISTINCT prd_key) AS "Total Products"
FROM analytics.products_dim
GROUP BY cat
ORDER BY "Total Products" DESC;

-- 4. Average product cost by category
SELECT
    cat AS "Category",
    ROUND(AVG(prd_cost), 2) AS "Average Product Cost"
FROM (
    SELECT 
        prd_key, cat, prd_cost
    FROM analytics.products_dim
    WHERE prd_end_date IS NULL
)
GROUP BY cat
ORDER BY "Average Product Cost" DESC;

-- 5. Total revenue by category
WITH active_products AS (
    SELECT 
        prd_key, cat, prd_cost
    FROM analytics.products_dim
    WHERE prd_end_date IS NULL
)
SELECT 
    cat AS "Category",
    SUM(sales_total) AS "Revenue"
FROM analytics.sales_fact s
LEFT JOIN active_products p ON s.prd_key = p.prd_key
GROUP BY cat
ORDER BY SUM(sales_total) DESC;

-- 6. Top 20 popular products
WITH products AS (
    SELECT DISTINCT prd_key, prd_name, cat, prd_cost
    FROM analytics.products_dim
    WHERE prd_end_date IS NULL
    ORDER BY prd_key
)
SELECT 
    p.prd_key,
    p.prd_name,
    p.cat,
    p.prd_cost,
    SUM(quantity) AS quantity
FROM analytics.sales_fact s
LEFT JOIN products p ON s.prd_key = p.prd_key
GROUP BY p.prd_key, p.prd_name, p.cat, p.prd_cost
ORDER BY quantity DESC
LIMIT 20;

-- 7. Top 20 revenue-generating products
WITH products AS (
    SELECT DISTINCT prd_key, prd_name, cat, prd_cost
    FROM analytics.products_dim
    WHERE prd_end_date IS NULL
    ORDER BY prd_key
)
SELECT 
    p.prd_key,
    p.prd_name,
    p.cat,
    p.prd_cost,
    SUM(sales_total) AS sales_total
FROM analytics.sales_fact s
LEFT JOIN products p ON s.prd_key = p.prd_key
GROUP BY p.prd_key, p.prd_name, p.cat, p.prd_cost
ORDER BY sales_total DESC
LIMIT 20;

-- 8. % of Revenue Top 20 Products Generated
WITH products AS (
    SELECT DISTINCT prd_key, prd_name, cat, prd_cost
    FROM analytics.products_dim
    WHERE prd_end_date IS NULL
    ORDER BY prd_key
),
top_20 AS (
SELECT 
    p.prd_key,
    p.prd_name,
    p.cat,
    p.prd_cost,
    SUM(sales_total) AS sales_total
FROM analytics.sales_fact s
LEFT JOIN products p ON s.prd_key = p.prd_key
GROUP BY p.prd_key, p.prd_name, p.cat, p.prd_cost
ORDER BY sales_total DESC
LIMIT 20
),
total_revenue AS (
    SELECT SUM(sales_total) AS total_sales
    FROM analytics.sales_fact
),
top_20_revenue AS (
    SELECT SUM(sales_total) AS top_20_sales
    FROM top_20
)
SELECT ROUND((top_20_sales/total_sales) * 100, 2) AS "Top 20 Revenue (% from Total)"
FROM top_20_revenue, total_revenue;

-- 9. Products never sold
SELECT DISTINCT prd_key, prd_name, cat
FROM analytics.products_dim
WHERE prd_key NOT IN (
    SELECT DISTINCT prd_key
    FROM analytics.sales_fact
)

-- 10. Top 10 customers by sales
SELECT 
    c.cust_id, 
    c.cust_firstname, 
    c.cust_lastname,
    c.cust_country, 
    SUM(sales_total) AS "total_sales"
FROM analytics.sales_fact s
LEFT JOIN analytics.customers_dim c ON s.cust_id = c.cust_id
GROUP BY c.cust_id
ORDER BY "total_sales" DESC
LIMIT 10;

-- 11. Sales by Country
SELECT 
    c.cust_country AS "Country",
    SUM(s.quantity) AS "Items Sold",
    SUM(s.sales_total) AS "Revenue"
FROM analytics.sales_fact s
LEFT JOIN analytics.customers_dim c ON s.cust_id = c.cust_id
GROUP BY c.cust_country
ORDER BY "Items Sold" DESC;

-- 12. Shipping Time Distribution (in days)
SELECT
    ship_date - order_date AS "Shipping Time in Days",
    COUNT(*) AS "Number of Orders"
FROM analytics.sales_fact
GROUP BY ship_date - order_date
ORDER BY "Shipping Time in Days";



-- Profit Analysis

-- 1. Gross Margin Percentage
WITH earliest_cost AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS rn
        FROM analytics.products_dim
    )
    WHERE rn = 1
),
margins AS (
SELECT
    s.order_date,
    s.prd_key,
    COALESCE(p.cat, e.cat) AS cat,
    s.sales_total,
    s.quantity,
    (s.sales_total / s.quantity) AS price_per_item,
    COALESCE(p.prd_cost, e.prd_cost) AS cost_per_item,
    (s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost) AS margin_per_item,
    ((s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost))::numeric/(s.sales_total / s.quantity) AS margin_pct
FROM analytics.sales_fact s
LEFT JOIN analytics.products_dim p
ON s.prd_key = p.prd_key
AND s.order_date >= p.prd_start_date
AND (s.order_date <= p.prd_end_date OR p.prd_end_date IS NULL)
LEFT JOIN earliest_cost e
ON s.prd_key = e.prd_key
ORDER BY quantity DESC
)
SELECT 
    SUM(sales_total) AS total_sales,
    SUM(margin_per_item*quantity) AS total_margin,
    ROUND((SUM(margin_per_item*quantity)::numeric/SUM(sales_total))*100.0, 2) AS gross_margin_pct
FROM margins

-- 2. Top 20 Profit-Generating Products
WITH earliest_cost AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS rn
        FROM analytics.products_dim
    )
    WHERE rn = 1
),
margins AS (
SELECT
    s.order_date,
    s.prd_key,
    COALESCE(p.cat, e.cat) AS cat,
    s.sales_total,
    s.quantity,
    (s.sales_total / s.quantity) AS price_per_item,
    COALESCE(p.prd_cost, e.prd_cost) AS cost_per_item,
    (s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost) AS margin_per_item,
    ((s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost))::numeric/(s.sales_total / s.quantity) AS margin_pct
FROM analytics.sales_fact s
LEFT JOIN analytics.products_dim p
ON s.prd_key = p.prd_key
AND s.order_date >= p.prd_start_date
AND (s.order_date <= p.prd_end_date OR p.prd_end_date IS NULL)
LEFT JOIN earliest_cost e
ON s.prd_key = e.prd_key
ORDER BY quantity DESC
)
SELECT
    prd_key,
    cat,
    SUM(sales_total) AS total_sales,
    SUM(margin_per_item*quantity) AS total_margin,
    ROUND((SUM(margin_per_item*quantity)::numeric/SUM(sales_total))*100.0, 2) AS gross_margin_pct
FROM margins
GROUP BY prd_key, cat
ORDER BY total_margin DESC
LIMIT 20;

-- 3. Top 20 Most Profitable Products per Item
WITH earliest_cost AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS rn
        FROM analytics.products_dim
    )
    WHERE rn = 1
),
margins AS (
SELECT
    s.order_date,
    s.prd_key,
    COALESCE(p.cat, e.cat) AS cat,
    s.sales_total,
    s.quantity,
    (s.sales_total / s.quantity) AS price_per_item,
    COALESCE(p.prd_cost, e.prd_cost) AS cost_per_item,
    (s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost) AS margin_per_item,
    ((s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost))::float/(s.sales_total / s.quantity)::float AS margin_pct
FROM analytics.sales_fact s
LEFT JOIN analytics.products_dim p
ON s.prd_key = p.prd_key
AND s.order_date >= p.prd_start_date
AND (s.order_date <= p.prd_end_date OR p.prd_end_date IS NULL)
LEFT JOIN earliest_cost e
ON s.prd_key = e.prd_key
)
SELECT 
    prd_key,
    cat,
    SUM(margin_per_item*quantity)/(SUM(quantity)) AS avg_profit_per_unit,
    SUM(price_per_item*quantity)/(SUM(quantity)) AS avg_selling_price,
    (SUM(margin_per_item*quantity)/(SUM(quantity)))::float/(SUM(price_per_item*quantity)/(SUM(quantity)))::float AS product_gross_margin_pct
FROM margins
GROUP BY prd_key, cat
ORDER BY (SUM(margin_per_item*quantity)/(SUM(quantity)))::float/(SUM(price_per_item*quantity)/(SUM(quantity)))::float DESC
LIMIT 20;




-- Time Series Analysis

-- 1. Sales Performance per year
SELECT
    DATE_PART('year', order_date) AS "Year",
    SUM(sales_total) AS "Total Sales",
    COUNT(DISTINCT cust_id) AS "Total Customers",
    COUNT(DISTINCT order_num) AS "Total Orders",
    SUM(quantity) AS "Total Quantity",
    SUM(sales_total)/COUNT(DISTINCT order_num) AS "Average Order Value"
FROM analytics.sales_fact
GROUP BY "Year"
ORDER BY "Year";

-- 2. Sales Performance per month
SELECT
    DATE_PART('month', order_date) AS "Month",
    SUM(sales_total) AS "Total Sales",
    COUNT(DISTINCT cust_id) AS "Total Customers",
    COUNT(DISTINCT order_num) AS "Total Orders",
    SUM(quantity) AS "Total Quantity"
FROM analytics.sales_fact
GROUP BY "Month"
ORDER BY "Month";

-- 3. Sales vs Margin year-by-year analysis
WITH earliest_cost AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS rn
        FROM analytics.products_dim
    )
    WHERE rn = 1
),
margins AS (
SELECT
    s.order_date,
    s.prd_key,
    COALESCE(p.cat, e.cat) AS cat,
    s.sales_total,
    s.quantity,
    (s.sales_total / s.quantity) AS price_per_item,
    COALESCE(p.prd_cost, e.prd_cost) AS cost_per_item,
    (s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost) AS margin_per_item,
    ((s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost))::float/(s.sales_total / s.quantity)::float AS margin_pct
FROM analytics.sales_fact s
LEFT JOIN analytics.products_dim p
ON s.prd_key = p.prd_key
AND s.order_date >= p.prd_start_date
AND (s.order_date <= p.prd_end_date OR p.prd_end_date IS NULL)
LEFT JOIN earliest_cost e
ON s.prd_key = e.prd_key
)
SELECT 
    DATE_PART('year', order_date) AS "Year",
    SUM(sales_total) AS "Total Revenue",
    ROUND((SUM(sales_total)-LAG(SUM(sales_total)) OVER (ORDER BY DATE_PART('year', order_date)))::numeric/LAG(SUM(sales_total)) OVER (ORDER BY DATE_PART('year', order_date)) * 100, 2) AS "Year-Over-Year Revenue Growth (%)",
    SUM(margin_per_item*quantity) AS "Total Gross Profit",
    ROUND((SUM(margin_per_item*quantity)-LAG(SUM(margin_per_item*quantity)) OVER (ORDER BY DATE_PART('year', order_date)))::numeric/LAG(SUM(margin_per_item*quantity)) OVER (ORDER BY DATE_PART('year', order_date)) * 100, 2) AS "Year-Over-Year Profit Growth (%)",
    ROUND((SUM(margin_per_item*quantity)::numeric/SUM(sales_total) * 100.0) - LAG(SUM(margin_per_item*quantity)::numeric/SUM(sales_total) * 100.0) OVER (ORDER BY DATE_PART('year', order_date)), 2) AS "Margin Change (%)"
FROM margins
WHERE DATE_PART('year', order_date) BETWEEN 2011 AND 2013
GROUP BY "Year"
ORDER BY "Year";

-- 4. Sales vs Margin month-by-month analysis
WITH earliest_cost AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS rn
        FROM analytics.products_dim
    )
    WHERE rn = 1
),
margins AS (
SELECT
    s.order_date,
    s.prd_key,
    COALESCE(p.cat, e.cat) AS cat,
    s.sales_total,
    s.quantity,
    (s.sales_total / s.quantity) AS price_per_item,
    COALESCE(p.prd_cost, e.prd_cost) AS cost_per_item,
    (s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost) AS margin_per_item,
    ((s.sales_total / s.quantity) - COALESCE(p.prd_cost, e.prd_cost))::float/(s.sales_total / s.quantity)::float AS margin_pct
FROM analytics.sales_fact s
LEFT JOIN analytics.products_dim p
ON s.prd_key = p.prd_key
AND s.order_date >= p.prd_start_date
AND (s.order_date <= p.prd_end_date OR p.prd_end_date IS NULL)
LEFT JOIN earliest_cost e
ON s.prd_key = e.prd_key
)
SELECT 
    TO_CHAR(order_date, 'Month') AS "Month",
    DATE_PART('year', order_date) AS "Year",
    SUM(sales_total) AS "Total Revenue",
    ROUND((SUM(sales_total)-LAG(SUM(sales_total)) OVER (ORDER BY DATE_PART('year', order_date), DATE_PART('month', order_date)))::numeric/LAG(SUM(sales_total)) OVER (ORDER BY DATE_PART('year', order_date), DATE_PART('month', order_date)) * 100, 2) AS "Revenue Growth (%)",
    SUM(margin_per_item*quantity) AS "Total Gross Profit",
    ROUND((SUM(margin_per_item*quantity)-LAG(SUM(margin_per_item*quantity)) OVER (ORDER BY DATE_PART('year', order_date), DATE_PART('month', order_date)))::numeric/LAG(SUM(margin_per_item*quantity)) OVER (ORDER BY DATE_PART('year', order_date), DATE_PART('month', order_date)) * 100, 2) AS "Profit Growth (%)",
    ROUND((SUM(margin_per_item*quantity)::numeric/SUM(sales_total) * 100.0) - LAG(SUM(margin_per_item*quantity)::numeric/SUM(sales_total) * 100.0) OVER (ORDER BY DATE_PART('year', order_date), DATE_PART('month', order_date)), 2) AS "Margin Change (%)"
FROM margins
WHERE DATE_PART('year', order_date) BETWEEN 2011 AND 2013
GROUP BY DATE_PART('month', order_date), DATE_PART('year', order_date), TO_CHAR(order_date, 'Month');




-- Diving deeper to understand sales (Yearly and Monthly Trends)

-- 1. First vs Repeat Orders by Year
WITH cust_first_order AS (
    SELECT 
        cust_id,
        MIN(order_date) AS first_order
    FROM analytics.sales_fact
    GROUP BY cust_id
),
sales AS (
    SELECT 
        cust_id,
        order_num,
        order_date
    FROM analytics.sales_fact
    GROUP BY cust_id, order_num, order_date
),
orders AS (
    SELECT 
        s.cust_id,
        cfo.first_order,
        s.order_date
    FROM sales s
    LEFT JOIN cust_first_order cfo 
        ON s.cust_id = cfo.cust_id
)
SELECT
    DATE_PART('year', order_date) AS "Year",
    SUM(
        CASE 
            WHEN first_order = order_date THEN 1
            ELSE 0
        END
    ) AS "First Order",
    SUM(
        CASE 
            WHEN first_order <> order_date THEN 1
            ELSE 0
        END
    ) AS "Repeat Order"
FROM orders
WHERE DATE_PART('year', order_date) BETWEEN 2011 AND 2013
GROUP BY "Year"
ORDER BY "Year";

-- 2. Average total per order by year
WITH order_totals AS (
    SELECT 
        order_num,
        DATE_PART('year', order_date) AS "Year",
        SUM(sales_total) AS "Total Sales",
        SUM(quantity) AS "Total Quantity"
    FROM analytics.sales_fact
    GROUP BY order_num, "Year"
)
SELECT
    "Year",
    ROUND(AVG("Total Sales"), 2) AS "Average Total per Order",
    ROUND(AVG("Total Quantity"), 2) AS "Average Quantity per Order"
FROM order_totals
WHERE "Year" BETWEEN 2011 AND 2013
GROUP BY "Year"
ORDER BY "Year";

-- 3. Distribution of product costs by year added
WITH products AS (
    SELECT
        prd_id,
        prd_name,
        DATE_PART('year', MIN(prd_start_date)) AS year_added,
        prd_cost
    FROM analytics.products_dim
    GROUP BY prd_id, prd_name, prd_cost
    HAVING DATE_PART('year', MIN(prd_start_date)) BETWEEN 2011 AND 2013
    
)
SELECT
    year_added,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY prd_cost) AS median_cost,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY prd_cost) AS p25_cost,
    COUNT(*) AS products_added
FROM products
GROUP BY year_added
ORDER BY year_added;
