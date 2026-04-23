/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

/* =========================================================
   🧱 GOLD LAYER - DIMENSION: CUSTOMERS
========================================================= */
CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_create_date) AS customer_key,
    
    ci.cst_id            AS customer_id,
    ci.cst_key           AS customer_number,
    ci.cst_firstname     AS first_name,
    ci.cst_lastname      AS last_name,
    
    la.CNTRY             AS country,
    ci.cst_material_status AS marital_status,

    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.GEN, 'n/a')
    END                  AS gender,

    ca.BDATE             AS birthdate,
    ci.cst_create_date   AS create_date

FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_CUST_AZ12 ca
    ON ci.cst_key = ca.CID
LEFT JOIN Silver.erp_LOC_A101 la
    ON ci.cst_key = la.CID;



/* =========================================================
   📦 GOLD LAYER - DIMENSION: PRODUCTS
========================================================= */
CREATE VIEW gold.dim_product AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,

    pn.prd_id        AS product_id,
    pn.prd_key       AS product_number,
    pn.prd_nm        AS product_name,

    pn.Cat_Id        AS category_id,
    pc.cat           AS category,
    pc.SUBCAT        AS subcategory,
    pc.MAINTENANCE   AS maintenance_required,

    pn.prd_cost      AS cost,
    pn.prd_line      AS product_line,
    pn.prd_start_dt  AS start_date

FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_PX_CAT_G1V2 pc
    ON pn.Cat_Id = pc.ID
WHERE pn.prd_end_dt IS NULL;



/* =========================================================
   💰 GOLD LAYER - FACT: SALES
========================================================= */
CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num   AS order_number,

    pr.product_key,
    cu.customer_key,

    sd.sls_order_dt  AS order_date,
    sd.sls_ship_dt   AS shipping_date,
    sd.sls_due_dt    AS due_date,

    sd.sls_sales     AS sales_amount,
    sd.sls_quantity  AS quantity,
    sd.sls_price     AS price

FROM Silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
