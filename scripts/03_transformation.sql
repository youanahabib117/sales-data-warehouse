-- Applying transformations to each table as a view in the raw schema

-- Staging view for crm_customers, performing data cleaning and transformation
CREATE OR REPLACE VIEW raw.stg_crm_customers AS
WITH cleaned_crm_customers AS (
    SELECT 
        CAST(cst_id AS INTEGER) AS cst_id,
        TRIM(cst_firstname) AS cst_firstname, 
        TRIM(cst_lastname) AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            ELSE NULL
            END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE NULL
            END AS cst_gndr,
        CASE 
            WHEN DATE(cst_create_date) > DATE('now')
            THEN NULL
            ELSE DATE(cst_create_date)
            END AS cst_create_date
    FROM raw.crm_customers
    WHERE NOT (cst_id IS NULL
    AND cst_firstname IS NULL
    AND cst_lastname IS NULL)
    ),
ranked_crm_customers AS (
SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY cst_id
        ORDER BY cst_create_date DESC)
    AS row_num
FROM cleaned_crm_customers
)
SELECT
    cst_id,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM ranked_crm_customers
WHERE row_num = 1;

-- Staging view for crm_products, performing data cleaning and transformation
CREATE OR REPLACE VIEW raw.stg_crm_products AS
SELECT 
    CAST(prd_id AS INTEGER) AS prd_id,
    SUBSTRING(TRIM(prd_key), 1, 5) AS cat_id,
    SUBSTRING(TRIM(prd_key), 7, LENGTH(prd_key)) AS prd_key,
    TRIM(prd_nm) as prd_nm,
    CAST(prd_cost AS INTEGER) AS prd_cost,
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE NULL
        END AS prd_line,
    prd_start_dt::date as prd_start_dt,
    CASE
        WHEN LEAD(prd_start_dt::date) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt::date) > prd_start_dt::date
        THEN (LEAD(prd_start_dt::date) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt::date) - INTERVAL '1 day')::date
        ELSE NULL
        END AS prd_end_dt
FROM raw.crm_products;


-- Staging view for crm_sales, performing data cleaning and transformation
CREATE OR REPLACE VIEW raw.stg_crm_sales AS
WITH cleaned_crm_sales AS (
    SELECT
        CAST(sls_ord_num AS TEXT) || '-' || CAST(sls_prd_key AS TEXT) AS sls_ord_key,
        sls_ord_num,
        sls_prd_key,
        CAST(sls_cust_id AS INTEGER) AS sls_cust_id,
        CASE 
            WHEN LENGTH(sls_order_dt) = 8
            THEN DATE(
                SUBSTRING(sls_order_dt, 1, 4) || '-' || 
                SUBSTRING(sls_order_dt, 5, 2) || '-' || 
                SUBSTRING(sls_order_dt, 7, 2))
            ELSE NULL
            END AS sls_order_dt,
        CASE 
            WHEN LENGTH(sls_ship_dt) = 8
            THEN DATE(
                SUBSTRING(sls_ship_dt, 1, 4) || '-' || 
                SUBSTRING(sls_ship_dt, 5, 2) || '-' || 
                SUBSTRING(sls_ship_dt, 7, 2))
            ELSE NULL
            END AS sls_ship_dt,
        CASE 
            WHEN LENGTH(sls_due_dt) = 8
            THEN DATE(
                SUBSTRING(sls_due_dt, 1, 4) || '-' || 
                SUBSTRING(sls_due_dt, 5, 2) || '-' || 
                SUBSTRING(sls_due_dt, 7, 2))
            ELSE NULL
            END AS sls_due_dt,
        CASE
            WHEN sls_sales IS NULL OR sls_sales::INTEGER <= 0 OR sls_sales::INTEGER != (ABS(sls_price::INTEGER) * sls_quantity::INTEGER)
            THEN (ABS(sls_price::INTEGER) * sls_quantity::INTEGER)
            ELSE sls_sales::INTEGER
            END AS sls_sales,
        sls_quantity::INTEGER AS sls_quantity, 
        CASE
            WHEN sls_price IS NULL OR sls_price::INTEGER <= 0
            THEN (sls_sales::INTEGER / sls_quantity::INTEGER)
            ELSE sls_price::INTEGER
            END AS sls_price
    FROM raw.crm_sales
    )
SELECT sls_ord_key,
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    COALESCE(sls_order_dt, sls_due_dt-12) AS sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM cleaned_crm_sales;


-- Staging view for erp_customers, performing data cleaning and transformation
CREATE OR REPLACE VIEW raw.stg_erp_customers AS
SELECT
    CASE
        WHEN CID LIKE 'NAS%'
        THEN SUBSTRING(CID, 9, LENGTH(CID))::integer
        ELSE SUBSTRING(CID, 4, LENGTH(CID))::integer
        END AS CID,
    CASE
        WHEN SUBSTRING(BDATE, 1, 4)::INTEGER > EXTRACT(YEAR FROM CURRENT_DATE)
        THEN ('1900' || SUBSTRING(BDATE, 5))::date
        ELSE BDATE::date
        END AS BDATE,
    CASE
        WHEN UPPER(TRIM(GEN)) = 'MALE' OR UPPER(TRIM(GEN)) = 'M'
        THEN 'Male'
        WHEN UPPER(TRIM(GEN)) = 'FEMALE' OR UPPER(TRIM(GEN)) = 'F'
        THEN 'Female'
        ELSE NULL
        END AS GEN
FROM raw.erp_customers;


-- Staging view for erp_locations, performing data cleaning and transformation
CREATE OR REPLACE VIEW raw.stg_erp_locations AS
SELECT
    SUBSTRING(CID, 7, LENGTH(CID))::integer AS CID,
    CASE
        WHEN UPPER(TRIM(CNTRY)) = 'AUSTRALIA'
        THEN 'Australia'
        WHEN UPPER(TRIM(CNTRY)) = 'US' OR UPPER(TRIM(CNTRY)) = 'USA' OR UPPER(TRIM(CNTRY)) = 'UNITED STATES'
        THEN 'United States'
        WHEN UPPER(TRIM(CNTRY)) = 'DE' OR UPPER(TRIM(CNTRY)) = 'GERMANY'
        THEN 'Germany'
        WHEN UPPER(TRIM(CNTRY)) = 'CANADA'
        THEN 'Canada'
        WHEN UPPER(TRIM(CNTRY)) = 'UNITED KINGDOM'
        THEN 'United Kingdom'
        WHEN UPPER(TRIM(CNTRY)) = 'FRANCE'
        THEN 'France'
        ELSE NULL
        END AS CNTRY
FROM raw.erp_locations;


-- Staging view for erp_product_categories, performing data cleaning and transformation
CREATE OR REPLACE VIEW raw.stg_erp_product_categories AS
SELECT
    REPLACE(ID, '_', '-') AS ID,
    CAT,
    SUBCAT,
    MAINTENANCE
FROM raw.erp_product_categories;
