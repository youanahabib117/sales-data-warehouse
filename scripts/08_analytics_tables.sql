-- Creating the fact table
DROP TABLE IF EXISTS analytics.sales_fact;

CREATE TABLE analytics.sales_fact (
    order_key TEXT PRIMARY KEY,
    order_num TEXT,
    prd_key TEXT,
    cust_id INTEGER,
    order_date DATE,
    ship_date DATE,
    due_date DATE,
    sales_total INTEGER,
    quantity INTEGER,
    price INTEGER
)



-- Creating the dimension tables
DROP TABLE IF EXISTS analytics.customers_dim;

CREATE TABLE analytics.customers_dim (
    cust_id INTEGER PRIMARY KEY,
    cust_firstname TEXT,
    cust_lastname TEXT,
    cust_marital_status TEXT,
    cust_gender TEXT,
    cust_create_date DATE,
    cust_birthday DATE,
    cust_country TEXT
);


DROP TABLE IF EXISTS analytics.products_dim;

CREATE TABLE analytics.products_dim (
    prd_id INTEGER PRIMARY KEY,
    prd_key TEXT,
    prd_name TEXT,
    prd_line TEXT,
    prd_cost INTEGER,
    prd_start_date DATE,
    prd_end_date DATE,
    cat TEXT,
    subcat TEXT,
    maintenance TEXT
);


-- Populating the dimension tables with views from the relational schema

INSERT INTO analytics.sales_fact(
    order_key,
    order_num,
    prd_key,
    cust_id,
    order_date,
    ship_date,
    due_date,
    sales_total,
    quantity,
    price
)
SELECT
    order_key,
    order_num,
    prd_key,
    cust_id,
    order_date,
    ship_date,
    due_date,
    sales_total,
    quantity,
    price
FROM relational.stg_sales_fact; 

INSERT INTO analytics.customers_dim(
    cust_id,
    cust_firstname,
    cust_lastname,
    cust_marital_status,
    cust_gender,
    cust_create_date,
    cust_birthday,
    cust_country
)
SELECT
    cust_id,
    cust_firstname,
    cust_lastname,
    cust_marital_status,
    cust_gender,
    cust_create_date,
    cust_birthday,
    cust_country
FROM relational.stg_customers_dim;

INSERT INTO analytics.products_dim(
    prd_id,
    prd_key,
    prd_name,
    prd_line,
    prd_cost,
    prd_start_date,
    prd_end_date,
    cat,
    subcat,
    maintenance
)
SELECT 
    prd_id,
    prd_key,
    prd_name,
    prd_line,
    prd_cost,
    prd_start_date,
    prd_end_date,
    cat,
    subcat,
    maintenance
FROM relational.stg_products_dim;