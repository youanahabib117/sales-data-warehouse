-- Creating tables in the raw schema to load data from .csv files


-- Creating crm_customers table in the raw schema after dropping it if it already exists to avoid issues during the load
DROP TABLE IF EXISTS raw.crm_customers;

CREATE TABLE raw.crm_customers (
    cst_id TEXT,
    cst_key TEXT,
    cst_firstname TEXT,
    cst_lastname TEXT,
    cst_marital_status TEXT,
    cst_gndr TEXT,
    cst_create_date TEXT);


-- Creating crm_products table in the raw schema after dropping it if it already exists to avoid issues during the load
DROP TABLE IF EXISTS raw.crm_products;

CREATE TABLE raw.crm_products (
    prd_id TEXT,
    prd_key TEXT,
    prd_nm TEXT,
    prd_cost TEXT,
    prd_line TEXT,
    prd_start_dt TEXT,
    prd_end_dt TEXT);


-- Creating crm_sales table in the raw schema after dropping it if it already exists to avoid issues during the load
DROP TABLE IF EXISTS raw.crm_sales;

CREATE TABLE raw.crm_sales (
    sls_ord_num TEXT,
    sls_prd_key TEXT,
    sls_cust_id TEXT,
    sls_order_dt TEXT,
    sls_ship_dt TEXT,
    sls_due_dt TEXT,
    sls_sales TEXT,
    sls_quantity TEXT,
    sls_price TEXT);

-- Creating erp_customers table in the raw schema after dropping it if it already exists to avoid issues during the load
DROP TABLE IF EXISTS raw.erp_customers;

CREATE TABLE raw.erp_customers (
    CID TEXT,
    BDATE TEXT,
    GEN TEXT);

-- Creating erp_locations table in the raw schema after dropping it if it already exists to avoid issues during the load
DROP TABLE IF EXISTS raw.erp_locations;

CREATE TABLE raw.erp_locations (
    CID TEXT,
    CNTRY TEXT);


-- Creating erp_product_categories table in the raw schema after dropping it if it already exists to avoid issues during the load
DROP TABLE IF EXISTS raw.erp_product_categories;

CREATE TABLE raw.erp_product_categories (
    ID TEXT,
    CAT TEXT,
    SUBCAT TEXT,
    MAINTENANCE TEXT);

-- At this point, data in .csv files was loaded into the respective tables in PostgreSQL
-- To do this, sales_data > Schema > raw > Tables > right click on the table > Import/Export > Import > select the .csv file > Options > Header: Yes, Delimiter: Comma
-- Do this for all six tables: crm_customers, crm_products, crm_sales, erp_customers, erp_locations, erp_product_categories