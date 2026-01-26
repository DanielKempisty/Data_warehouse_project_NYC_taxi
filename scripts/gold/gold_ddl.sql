/*
=============================================================
DDL script: Create gold layer tables
=============================================================
Script purpose:
	This script creates tables for gold layer in 'gold' schema.
	If tables exists, they are dropped and recreated.
	Run this query to (re)create the DDL structucre for gold layer.

WARNING:
	Running this script will drop all tables from 'gold' schema. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

------------------------------------------------------
-- 1. Fact_trips
------------------------------------------------------
IF OBJECT_ID('gold.fact_trips', 'U') IS NOT NULL
	DROP TABLE gold.fact_trips;
GO

CREATE TABLE gold.fact_trips (
	taxi_type_id			TINYINT NOT NULL,
	pu_date_key				BIGINT NOT NULL,
	pu_hour					TIME(0) NOT NULL,
	do_date_key				BIGINT NOT NULL,
	do_hour					TIME(0) NOT NULL,
	trip_time				INT NOT NULL,
	pu_borough_id			TINYINT NOT NULL,
	do_borough_id			TINYINT NOT NULL,
	trip_distance			DECIMAL(8,2) NOT NULL,
	distance_bucket_id		TINYINT NOT NULL,
	fare_amount				DECIMAL(8,2) NOT NULL,
	tip_amount				DECIMAL(8,2) NOT NULL,
	is_tip					BIT NOT NULL,
	tolls_amount			DECIMAL(8,2) NOT NULL,
	improvement_surcharge	DECIMAL(8,2) NOT NULL,
	congestion_surcharge	DECIMAL(8,2) NOT NULL,
	airport_fee				DECIMAL(8,2) NOT NULL,
	mta_tax					DECIMAL(8,2) NOT NULL,
	extra					DECIMAL(8,2) NOT NULL,
	ehail_fee				DECIMAL(8,2) NOT NULL,
	bcf_fee					DECIMAL(8,2) NOT NULL,
	sales_tax				DECIMAL(8,2) NOT NULL,
	total_amount			DECIMAL(8,2) NOT NULL,
	trips_cnt				INT NOT NULL
);
GO

------------------------------------------------------
-- 2. Fact_weather
------------------------------------------------------
IF OBJECT_ID('gold.fact_weather', 'U') IS NOT NULL
	DROP TABLE gold.fact_weather;
GO

CREATE TABLE gold.fact_weather (
	weather_date_key				BIGINT NOT NULL,
	temperature_mean				DECIMAL(7,2) NULL,
	temperature_mean_category		NVARCHAR(50) NULL,
	precipitation_total				DECIMAL(7,2) NULL,
	precipitation_total_category	NVARCHAR(50) NULL,
	visibility						DECIMAL(7,2) NULL,
	visibility_category				NVARCHAR(50) NULL,
	snow_depth						DECIMAL(7,2) NULL,
	snow_depth_category				NVARCHAR(50) NULL,
	wind_speed_mean					DECIMAL(7,2) NULL,
	wind_speed_mean_cateogry		NVARCHAR(50) NULL,
	is_fog							VARCHAR(3) NOT NULL,
	is_rain_or_drizzle				VARCHAR(3) NOT NULL,
	is_hail							VARCHAR(3) NOT NULL,
	is_thunder						VARCHAR(3) NOT NULL,
	is_tornado_or_funnel_cloud		VARCHAR(3) NOT NULL
);
GO

------------------------------------------------------
-- 3. Fact_events
------------------------------------------------------
IF OBJECT_ID('gold.fact_events', 'U') IS NOT NULL
	DROP TABLE gold.fact_events;
GO

CREATE TABLE gold.fact_events (
	event_date_key			BIGINT NOT NULL,
	agency_id				TINYINT NOT NULL,
	event_type_id			TINYINT NOT NULL,
	borough_id				TINYINT NOT NULL,
	street_closure_type_id	TINYINT NOT NULL,
	events_cnt				INT NOT NULL
);
GO

------------------------------------------------------
-- 4. Dim_taxi_type
------------------------------------------------------
IF OBJECT_ID('gold.dim_taxi_type', 'U') IS NOT NULL
	DROP TABLE gold.dim_taxi_type;
GO

CREATE TABLE gold.dim_taxi_type (
	taxi_type_id		TINYINT NOT NULL,
	taxi_type			NVARCHAR(20)
);
GO

------------------------------------------------------
-- 5. Dim_borough
------------------------------------------------------
IF OBJECT_ID('gold.dim_borough', 'U') IS NOT NULL
	DROP TABLE gold.dim_borough;
GO

CREATE TABLE gold.dim_borough (
	borough_id			TINYINT NOT NULL,
	borough_name		NVARCHAR(50) NOT NULL,
	is_airport			VARCHAR(3) NOT NULL
);
GO

------------------------------------------------------
-- 6. Dim_date
------------------------------------------------------
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
	DROP TABLE gold.dim_date;
GO

CREATE TABLE gold.dim_date (
	date_key			BIGINT NOT NULL,
	full_date			DATE NULL,
	quarter				TINYINT NULL,
	month				TINYINT NULL,
	day					TINYINT NULL,
	is_weekend			VARCHAR(3) NULL,
	is_holiday			VARCHAR(3) NULL,
	holiday_name		NVARCHAR(255) NULL
);
GO

------------------------------------------------------
-- 7. Dim_event_agency
------------------------------------------------------
IF OBJECT_ID('gold.dim_event_agency', 'U') IS NOT NULL
	DROP TABLE gold.dim_event_agency;
GO

CREATE TABLE gold.dim_event_agency (
	agency_id		TINYINT NOT NULL,
	agency			NVARCHAR(255)
);
GO

------------------------------------------------------
-- 8. Dim_event_type
------------------------------------------------------
IF OBJECT_ID('gold.dim_event_type', 'U') IS NOT NULL
	DROP TABLE gold.dim_event_type;
GO

CREATE TABLE gold.dim_event_type (
	event_type_id		TINYINT NOT NULL,
	event_type			NVARCHAR(255)
);
GO

------------------------------------------------------
-- 9. Dim_street_closure_type
------------------------------------------------------
IF OBJECT_ID('gold.dim_street_closure_type', 'U') IS NOT NULL
	DROP TABLE gold.dim_street_closure_type;
GO

CREATE TABLE gold.dim_street_closure_type (
	street_closure_type_id		TINYINT NOT NULL,
	street_closure_type			NVARCHAR(255)
);
GO

------------------------------------------------------
-- 10. Dim_trip_distance_bucket
------------------------------------------------------
IF OBJECT_ID('gold.dim_trip_distance_bucket', 'U') IS NOT NULL
	DROP TABLE gold.dim_trip_distance_bucket;
GO

CREATE TABLE gold.dim_trip_distance_bucket (
	distance_bucket_id			TINYINT NOT NULL,
	distance_bucket				NVARCHAR(5) NOT NULL
);
GO