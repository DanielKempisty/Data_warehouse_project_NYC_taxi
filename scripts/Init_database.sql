/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'NYC_taxi' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'NYC_taxi' database if it exists. 
    All data in the database will be permanently deleted. 
	Make sure there is no needed data in the database or it's backed up.
*/

USE master;
GO

-- Drop and recreate the 'NYC_taxi' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'NYC_taxi')
BEGIN
    ALTER DATABASE NYC_taxi SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NYC_taxi;
END;
GO

-- Create the 'NYC_taxi' database
CREATE DATABASE NYC_taxi;
GO

USE NYC_taxi;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO