-- Creating tables in the relational schema with appropriate data types and relational model format
-- Note: A new table, erp_product_history, has been created to store the history of product prices with start and end dates for each price record
-- This is important for the schema of the relational model


-- Creating erp_locations table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.erp_locations;
CREATE TABLE relational.erp_locations(
    CID INTEGER PRIMARY KEY,
    CNTRY TEXT);

-- Creating erp_customers table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.erp_customers;
CREATE TABLE relational.erp_customers(
    CID INTEGER PRIMARY KEY,
    BDATE DATE,
    GEN TEXT,
    FOREIGN KEY (CID) REFERENCES relational.erp_locations(CID));

-- Creating crm_customers table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.crm_customers;
CREATE TABLE relational.crm_customers(
    cst_id INTEGER PRIMARY KEY,
    cst_key TEXT UNIQUE,
    cst_firstname TEXT,
    cst_lastname TEXT,
    cst_marital_status TEXT,
    cst_gndr TEXT,
    cst_create_date DATE,
    FOREIGN KEY (cst_id) REFERENCES relational.erp_customers(CID));

-- Creating erp_product_categories table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.erp_product_categories;
CREATE TABLE relational.erp_product_categories(
    ID TEXT PRIMARY KEY,
    CAT TEXT,
    SUBCAT TEXT UNIQUE,
    MAINTENANCE TEXT);

-- Creating crm_products table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.crm_products;
CREATE TABLE relational.crm_products(
    prd_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cat_id TEXT,
    prd_key TEXT UNIQUE,
    prd_nm TEXT UNIQUE,
    prd_line TEXT,
    FOREIGN KEY (cat_id) REFERENCES relational.erp_product_categories(ID));

-- Creating crm_sales table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.crm_sales;
CREATE TABLE relational.crm_sales(
    sls_ord_key TEXT PRIMARY KEY,
    sls_ord_num TEXT,
    sls_prd_key TEXT,
    sls_cust_id INTEGER,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INTEGER,
    sls_quantity INTEGER,
    sls_price INTEGER,
    FOREIGN KEY (sls_prd_key) REFERENCES relational.crm_products(prd_key),
    FOREIGN KEY (sls_cust_id) REFERENCES relational.crm_customers(cst_id));


-- Creating erp_product_history table in the relational schema after dropping it if it already exists to avoid issues
DROP TABLE IF EXISTS relational.erp_product_history;
CREATE TABLE relational.erp_product_history(
    PRICE_ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PRD_ID INTEGER,
    PRD_COST INTEGER,
    PRD_START_DT DATE,
    PRD_END_DT DATE,
    FOREIGN KEY (PRD_ID) REFERENCES relational.crm_products(prd_id));



-- Inserting data from views into the relational tables to populate them with the transformed data

-- Inserting data into erp_locations
INSERT INTO relational.erp_locations(
    CID,
    CNTRY
)
SELECT
    CID,
    CNTRY
FROM raw.stg_erp_locations;


-- Inserting data into erp_customers
INSERT INTO relational.erp_customers(
    CID,
    BDATE,
    GEN
)
SELECT
    CID,
    BDATE,
    GEN
FROM raw.stg_erp_customers;


-- Inserting data into crm_customers
INSERT INTO relational.crm_customers(
    cst_id,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM raw.stg_crm_customers;


-- Inserting data into erp_product_categories
INSERT INTO relational.erp_product_categories(
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
)
SELECT
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
FROM raw.stg_erp_product_categories;


-- Inserting data into crm_products
INSERT INTO relational.crm_products(
    cat_id,
    prd_key,
    prd_nm,
    prd_line
)
SELECT DISTINCT
    p.cat_id,
    p.prd_key,
    p.prd_nm,
    p.prd_line
FROM raw.stg_crm_products p
JOIN relational.erp_product_categories c
ON p.cat_id = c.ID;


-- Inserrting data into crm_sales
INSERT INTO relational.crm_sales(
    sls_ord_key,
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_key,
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM raw.stg_crm_sales;


-- Inserting data into erp_product_history
INSERT INTO relational.erp_product_history (
    PRD_ID,
    PRD_COST,
    PRD_START_DT,
    PRD_END_DT
)
SELECT
    p.prd_id,
    s.prd_cost,
    s.prd_start_dt,
    s.prd_end_dt
FROM raw.stg_crm_products s
JOIN relational.crm_products p
ON s.prd_key = p.prd_key;