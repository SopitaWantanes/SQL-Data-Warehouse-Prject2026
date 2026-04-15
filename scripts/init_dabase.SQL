
/*
==========================================================
CREATE DATABASE AND SCHEMAS
==========================================================
SCRIPT PURPOSE:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the scrip sets up three schemas
	within the database: bronze, silver, and gold.

WARNING:
Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permantly deleted. Proceed with caution and ensure you have proper 
backups before running this scrip.
*/

USE master;
GO

--Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN
	ALTER DATABASE Datawarehouse  SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Datawarehouse;
	END;
	GO

--Create the 'DataWarehouse' database

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
