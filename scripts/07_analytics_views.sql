-- Changing structure into an analytics-friendly model (star schema)

-- Creating views in the relational schema to serve as the base for the analytical model

CREATE OR REPLACE VIEW relational.stg_sales_fact AS
SELECT
    sls_ord_key AS order_key,
    sls_ord_num AS order_num,
    sls_prd_key AS prd_key,
    sls_cust_id AS cust_id,
    sls_order_dt AS order_date,
    sls_ship_dt AS ship_date,
    sls_due_dt AS due_date,
    sls_sales AS sales_total,
    sls_quantity AS quantity,
    sls_price AS price
FROM relational.crm_sales;


CREATE OR REPLACE VIEW relational.stg_customers_dim AS
SELECT
    cc.cst_id AS cust_id,
    cc.cst_firstname AS cust_firstname,
    cc.cst_lastname AS cust_lastname,
    cc.cst_marital_status AS cust_marital_status,
    CASE 
        WHEN cc.cst_gndr IS NOT NULL
        THEN cc.cst_gndr
        ELSE ec.GEN
        END AS cust_gender,
    cc.cst_create_date AS cust_create_date,
    ec.bdate AS cust_birthday,
    el.cntry AS cust_country
FROM relational.crm_customers cc 
LEFT JOIN relational.erp_customers ec ON cc.cst_id = ec.cid
LEFT JOIN relational.erp_locations el ON ec.cid = el.cid;


CREATE OR REPLACE VIEW relational.stg_products_dim AS
SELECT
    p.prd_id AS prd_id,
    p.prd_key AS prd_key,
    p.prd_nm AS prd_name,
    p.prd_line AS prd_line,
    p.prd_cost AS prd_cost,
    p.prd_start_dt AS prd_start_date,
    p.prd_end_dt AS prd_end_date,
    pc.CAT AS cat,
    pc.SUBCAT AS subcat,
    pc.MAINTENANCE AS maintenance
FROM raw.stg_crm_products p
LEFT JOIN raw.stg_erp_product_categories pc ON p.cat_id = pc.ID;