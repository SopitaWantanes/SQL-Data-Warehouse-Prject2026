/*
==========================================================
DDL Script: Create Silver Tables
==========================================================
Script Purpose:
This Script creates tables in the 'Silver' schema, dropping tables
if they already exist.
Run this script to re-define the DDL Structure of 'Bronze' Tables
==========================================================
*/

IF OBJECT_ID ('Silver.crm_cust_info', 'U') IS NOT NULL
DROP TABLE Silver.crm_cust_info;

CREATE TABLE Silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
IF OBJECT_ID ('Silver.crm_prd_info', 'U') IS NOT NULL
DROP TABLE Silver.crm_prd_info;

CREATE TABLE Silver.crm_prd_info(
	prd_id	INT,
	Cat_Id NVARCHAR(50),
	prd_key	NVARCHAR(50),
	prd_nm	NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.crm_sales_details', 'U') IS NOT NULL
DROP TABLE Silver.crm_sales_details;

CREATE TABLE Silver.crm_sales_details(
	sls_ord_num	NVARCHAR(50),
	sls_prd_key	NVARCHAR(50),
	sls_cust_id	INT,
	sls_order_dt	DATE,
	sls_ship_dt	DATE,
	sls_due_dt	DATE,
	sls_sales INT,	
	sls_quantity	INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.erp_CUST_AZ12', 'U') IS NOT NULL
DROP TABLE Silver.erp_CUST_AZ12;

CREATE TABLE Silver.erp_CUST_AZ12(
	CID	NVARCHAR(50),
	BDATE DATE,
	GEN VARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.erp_LOC_A101', 'U') IS NOT NULL
DROP TABLE Silver.erp_LOC_A101;

CREATE TABLE Silver.erp_LOC_A101(
	CID	NVARCHAR(50),
	CNTRY NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('Silver.erp_PX_CAT_G1V2', 'U') IS NOT NULL
DROP TABLE Silver.erp_PX_CAT_G1V2;

CREATE TABLE Silver.erp_PX_CAT_G1V2(
	ID	VARCHAR(50),
	CAT	VARCHAR(50),
	SUBCAT	VARCHAR(50),
	MAINTENANCE VARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
