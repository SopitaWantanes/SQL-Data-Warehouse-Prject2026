/*
=======================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
======================================================================
Script Purpose:
This stored procedure loads data into the  'bronze' shcema from external CSV Files.
  - Truncates the bronze tables before loading data.
  - Uses the BULK INSERT command to load data from csv Files to bronze tables.
Parameters:
None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
========================================================================
*/

CREATE OR ALTER PROCEDURE Bronze.load_Bronze 
AS
	BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	
	BEGIN TRY
	SET @batch_start_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==============================================';

		PRINT '==============================================';
		PRINT 'Loading CRM Tables';
		PRINT '==============================================';

		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_cust_info';
		TRUNCATE TABLE Bronze.crm_cust_info;

		PRINT '>> Insert data into: Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
		FROM 'D:\RCAT\Web Portfolio\SQL Datawarehouse project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR= ',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>> Load Duration:'+ CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(20)) + 'Seconds';
		PRINT '>> -----------';

		--SELECT COUNT(*) FROM Bronze.crm_cust_info;
		
		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_prd_info'
		TRUNCATE TABLE Bronze.crm_prd_info;

		PRINT '>> Insert data into: Bronze.crm_prd_info'
		BULK INSERT Bronze.crm_prd_info
		FROM 'D:\RCAT\Web Portfolio\SQL Datawarehouse project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR= ',',
		TABLOCK
		);
		SET @end_time=GETDATE() ;
		PRINT '>> Load Duration :' + CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR(20)) + 'Seconds';
		PRINT '>> ----------';
	--	SELECT COUNT(*) FROM Bronze.crm_prd_info;

		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_sales_details'
		TRUNCATE TABLE Bronze.crm_sales_details;

		PRINT '>> Insert data into: Bronze.crm_sales_details'
		BULK INSERT Bronze.crm_sales_details
		FROM 'D:\RCAT\Web Portfolio\SQL Datawarehouse project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR= ',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(20)) + 'Seconds';
		PRINT '>>-----------'
	--	SELECT COUNT(*) FROM Bronze.crm_sales_details;

		PRINT '=============================================='
		PRINT 'Loading ERP Tables';
		PRINT '=============================================='

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_CUST_AZ12'
		TRUNCATE TABLE Bronze.erp_CUST_AZ12;

		PRINT '>> Insert data into: Bronze.erp_CUST_AZ12'
		BULK INSERT Bronze.erp_CUST_AZ12
		FROM 'D:\RCAT\Web Portfolio\SQL Datawarehouse project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR= ',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>> Loading Duration :' +  CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(20)) + 'Seconds';
		PRINT '>>-------------';

		--SELECT COUNT(*) FROM Bronze.erp_CUST_AZ12;
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_LOC_A101'
		TRUNCATE TABLE Bronze.erp_LOC_A101;

		PRINT '>> Insert data into: Bronze.erp_LOC_A101'
		BULK INSERT Bronze.erp_LOC_A101
		FROM 'D:\RCAT\Web Portfolio\SQL Datawarehouse project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR= ',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>> Loading Duration :' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(20)) + 'Seconds';
		PRINT '>>-------------';

		--SELECT COUNT(*) FROM Bronze.erp_LOC_A101;
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_PX_CAT_G1V2'
		TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;

		PRINT '>> Insert data into: Bronze.erp_PX_CAT_G1V2'
		BULK INSERT Bronze.erp_PX_CAT_G1V2
		FROM 'D:\RCAT\Web Portfolio\SQL Datawarehouse project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR= ',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>> Loading Duration :' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(20)) + ' Seconds';
		PRINT '>>-------------';

--	SELECT COUNT(*) FROM Bronze.erp_PX_CAT_G1V2;
SET @batch_end_time = GETDATE();
	PRINT '======================================================';
	PRINT 'Loading Bronze is Completed';
	PRINT ' - Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time,@batch_end_time) AS NVARCHAR(20)) + ' Seconds';
	PRINT '======================================================';
END TRY
BEGIN CATCH
	PRINT '======================================================';
	PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
	PRINT 'Error Message' + ERROR_MESSAGE();
	PRINT 'Error Number' + CAST (ERROR_NUMBER() AS NVARCHAR(10));
	PRINT 'Error State' + CAST (ERROR_STATE() AS NVARCHAR(10));
	PRINT '======================================================';
END CATCH
END;
GO
EXEC Bronze.load_Bronze;
