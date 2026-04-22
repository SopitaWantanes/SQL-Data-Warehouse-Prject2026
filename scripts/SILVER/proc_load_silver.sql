/*
=========================================================================
Stored Procedure: Load Silver (Bronze--> Silver)
=========================================================================
Script Purpose:
This stored procedure performance the ETL (Extact, Transform, Load) process to
populate the 'Silver' chema tables fro, the 'Bronze' schema.
Action preferred:
-Truncates Silver Tables.
- Inserts transformed and cleaned data from Bronze into Silver Tables.
Paremeters:
- Nome.
- This stored procedure does not accept any paramenters or return any values.
Usage Example:
  EXEC Silver.load_silver;
=======================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver
AS
BEGIN
    DECLARE 
        @Start_time        DATETIME,
        @End_time          DATETIME,
        @batch_start_time  DATETIME,
        @batch_end_time    DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '========================================';
        PRINT 'Loading Silver Layer';
        PRINT '========================================';

        PRINT '----------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------';

        /* ========================= (1) CUSTOMER ========================= */

        SET @Start_time = GETDATE();

        PRINT '>> Truncating Data Into: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname)  AS cst_lastname,
            cst_material_status,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,

            cst_create_date
        FROM (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS Flag_last
            FROM Bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) AS t
        WHERE Flag_last = 1;

        SET @End_time = GETDATE();

        PRINT '>> Load Duration:' 
            + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR(20)) 
            + ' Seconds';
        PRINT '>> -----------';

        /* ========================= (2) PRODUCT ========================= */

        SET @Start_time = GETDATE();

        PRINT '>> Truncating Data Into: Silver.crm_prd_info';
        TRUNCATE TABLE Silver.crm_prd_info;

        PRINT '>> Inserting Data Into: Silver.crm_prd_info';
        INSERT INTO Silver.crm_prd_info (
            [prd_id],
            [Cat_Id],
            [prd_key],
            [prd_nm],
            [prd_cost],
            [prd_line],
            [prd_start_dt],
            [prd_end_dt]
        )
        SELECT
            [prd_id],

            REPLACE(SUBSTRING([prd_key], 1, 5), '-', '_') AS [Cat_Id],
            SUBSTRING([prd_key], 7, LEN([prd_key]))       AS [prd_key],

            [prd_nm],
            ISNULL([prd_cost], 0)                         AS [prd_cost],

            CASE
                WHEN UPPER(TRIM([prd_line])) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM([prd_line])) = 'R' THEN 'Road'
                WHEN UPPER(TRIM([prd_line])) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM([prd_line])) = 'T' THEN 'Touring'
                ELSE 'N/A'
            END                                           AS [prd_line],

            CAST([prd_start_dt] AS date)                  AS [prd_start_dt],

            CAST(
                LEAD([prd_start_dt]) OVER (
                    PARTITION BY [prd_key]
                    ORDER BY [prd_start_dt]
                ) - 1
                AS date
            )                                             AS [prd_end_dt]

        FROM Bronze.crm_prd_info;

        SET @End_time = GETDATE();

        PRINT '>> Load Duration:' 
            + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR(20)) 
            + ' Seconds';
        PRINT '>> -----------';

        /* ========================= (3) SALES ========================= */

        SET @Start_time = GETDATE();

        PRINT '>> Truncating Data Into: Silver.crm_sales_details';
        TRUNCATE TABLE Silver.crm_sales_details;

        PRINT '>> Inserting Data Into: Silver.crm_sales_details';
        INSERT INTO Silver.crm_sales_details (
            [sls_ord_num],
            [sls_prd_key],
            [sls_cust_id],
            [sls_order_dt],
            [sls_ship_dt],
            [sls_due_dt],
            [sls_sales],
            [sls_quantity],
            [sls_price]
        )
        SELECT
            [sls_ord_num],
            [sls_prd_key],
            [sls_cust_id],

            CASE
                WHEN [sls_order_dt] = 0
                  OR LEN([sls_order_dt]) <> 8
                    THEN NULL
                ELSE CAST(CAST([sls_order_dt] AS varchar(8)) AS date)
            END AS [sls_order_dt],

            CASE
                WHEN [sls_ship_dt] = 0
                  OR LEN([sls_ship_dt]) <> 8
                    THEN NULL
                ELSE CAST(CAST([sls_ship_dt] AS varchar(8)) AS date)
            END AS [sls_ship_dt],

            CASE
                WHEN [sls_due_dt] = 0
                  OR LEN([sls_due_dt]) <> 8
                    THEN NULL
                ELSE CAST(CAST([sls_due_dt] AS varchar(8)) AS date)
            END AS [sls_due_dt],

            CASE
                WHEN [sls_sales] IS NULL
                  OR [sls_sales] <= 0
                  OR [sls_sales] <> [sls_quantity] * ABS([sls_price])
                    THEN [sls_quantity] * ABS([sls_price])
                ELSE [sls_sales]
            END AS [sls_sales],

            [sls_quantity],

            CASE
                WHEN [sls_price] IS NULL
                  OR [sls_price] <= 0
                    THEN [sls_sales] / NULLIF([sls_quantity], 0)
                ELSE [sls_price]
            END AS [sls_price]

        FROM [BRONZE].[crm_sales_details]
        WHERE [sls_prd_key] NOT IN (
            SELECT [prd_key]
            FROM [Silver].[crm_prd_info]
        );

        SET @End_time = GETDATE();

        PRINT '>> Load Duration:' 
            + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR(20)) 
            + ' Seconds';
        PRINT '>> -----------';

        /* ========================= (4) ERP CUSTOMER ========================= */

        SET @Start_time = GETDATE();

        PRINT '>> Truncating Data Into: Silver.erp_CUST_AZ12';
        TRUNCATE TABLE Silver.erp_CUST_AZ12;

        PRINT '>> Inserting Data Into: Silver.erp_CUST_AZ12';
        INSERT INTO Silver.erp_CUST_AZ12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
                ELSE 'n/a'
            END AS gen

        FROM Bronze.erp_CUST_AZ12;

        SET @End_time = GETDATE();

        PRINT '>> Load Duration:' 
            + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR(20)) 
            + ' Seconds';
        PRINT '>> -----------';

        /* ========================= (5) ERP LOCATION ========================= */

        SET @Start_time = GETDATE();

        PRINT '>> Truncating Data Into: Silver.erp_LOC_A101';
        TRUNCATE TABLE Silver.erp_LOC_A101;

        PRINT '>> Inserting Data Into: Silver.erp_LOC_A101';
        INSERT INTO Silver.erp_LOC_A101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,

            CASE
                WHEN TRIM(cntry) = 'DE'            THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA')  THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry

        FROM Bronze.erp_LOC_A101;

        SET @End_time = GETDATE();

        PRINT '>> Load Duration:' 
            + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR(20)) 
            + ' Seconds';
        PRINT '>> -----------';

        /* ========================= (6) ERP CATEGORY ========================= */

        SET @Start_time = GETDATE();

        PRINT '>> Truncating Data Into: Silver.erp_PX_CAT_G1V2';
        TRUNCATE TABLE Silver.erp_PX_CAT_G1V2;

        PRINT '>> Inserting Data Into: Silver.erp_PX_CAT_G1V2';
        INSERT INTO Silver.erp_PX_CAT_G1V2 (
            [ID],
            [CAT],
            [SUBCAT],
            [MAINTENANCE]
        )
        SELECT
            [ID],
            [CAT],
            [SUBCAT],
            [MAINTENANCE]
        FROM Bronze.erp_PX_CAT_G1V2;

        SET @End_time = GETDATE();

        PRINT '>> Load Duration:' 
            + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR(20)) 
            + ' Seconds';
        PRINT '>> -----------';

        /* ========================= FINAL ========================= */

        SET @batch_end_time = GETDATE();

        PRINT '======================================================';
        PRINT 'Loading Bronze is Completed';
        PRINT ' - Total Load Duration:'
            + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR(20))
            + ' Seconds';
        PRINT '======================================================';

    END TRY
    BEGIN CATCH
        PRINT '======================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State  : ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT '======================================================';
    END CATCH
END;
GO

EXEC Silver.load_silver;

