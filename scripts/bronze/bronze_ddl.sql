/*
=============================================================
DDL script: Create bronze layer tables
=============================================================
Script purpose:
	This script creates tables for bronze layer in 'bronze' schema: 
	If tables exists, they are dropped and recreated.
	Run this query to (re)create the DDL structucre for bronze layer.

WARNING:
	Running this script will drop all tables from 'bronze' schema. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

------------------------------------------------------
-- 1. Yellow taxi table
------------------------------------------------------
IF OBJECT_ID('bronze.td_yellow_taxi', 'U') IS NOT NULL
	DROP TABLE bronze.td_yellow_taxi;
GO

CREATE TABLE bronze.td_yellow_taxi (
	vendor_id				INT,
	pu_datetime				DATETIME2,
	do_datetime				DATETIME2,
	passenger_cnt			DECIMAL(18,4),
	trip_distance			DECIMAL(18,4),
	tariff_type				DECIMAL(18,4),
	store_and_fwd			NVARCHAR(20),
	pu_location_id			INT,
	do_location_id			INT,
	payment_type			DECIMAL(18,4),
	fare_amount				DECIMAL(18,4),
	extra					DECIMAL(18,4),
	mta_tax					DECIMAL(18,4),
	tip_amount				DECIMAL(18,4),
	tolls_amount			DECIMAL(18,4),
	improvement_surcharge	DECIMAL(18,4),
	total_amount			DECIMAL(18,4),
	congestion_surcharge	DECIMAL(18,4),
	airport_fee				DECIMAL(18,4)
);
GO

------------------------------------------------------
-- 2. Green taxi table
------------------------------------------------------
IF OBJECT_ID('bronze.td_green_taxi', 'U') IS NOT NULL
	DROP TABLE bronze.td_green_taxi;
GO

CREATE TABLE bronze.td_green_taxi (
	vendor_id				INT,
	pu_datetime				DATETIME2,
	do_datetime				DATETIME2,
	store_and_fwd			NVARCHAR(20),
	tariff_type				DECIMAL(18,4),
	pu_location_id			INT,
	do_location_id			INT,
	passenger_cnt			DECIMAL(18,4),
	trip_distance			DECIMAL(18,4),
	fare_amount				DECIMAL(18,4),
	extra					DECIMAL(18,4),
	mta_tax					DECIMAL(18,4),
	tip_amount				DECIMAL(18,4),
	tolls_amount			DECIMAL(18,4),
	ehail_fee				DECIMAL(18,4),
	improvement_surcharge	DECIMAL(18,4),
	total_amount			DECIMAL(18,4),
	payment_type			DECIMAL(18,4),
	trip_type				DECIMAL(18,4),
	congestion_surcharge	DECIMAL(18,4)
);
GO

------------------------------------------------------
-- 3. For-hire vehicle table
------------------------------------------------------
IF OBJECT_ID('bronze.td_for_hire', 'U') IS NOT NULL
	DROP TABLE bronze.td_for_hire;
GO

CREATE TABLE bronze.td_for_hire (
	hvfhs_license_num		NVARCHAR(20),
	dispatch_base_num		NVARCHAR(20),
	originate_base_num		NVARCHAR(20),
	request_datetime		DATETIME2,
	on_scene_datetime		DATETIME2,
	pu_datetime				DATETIME2,
	do_datetime				DATETIME2,
	pu_location_id			INT,
	do_location_id			INT,
	trip_distance			DECIMAL(18,4),
	trip_time				INT,
	base_passenger_fee		DECIMAL(18,4),
	tolls_amount			DECIMAL(18,4),
	bcf_fee					DECIMAL(18,4),
	sales_tax				DECIMAL(18,4),
	congestion_surcharge	DECIMAL(18,4),
	airport_fee				DECIMAL(18,4),
	tip_amount				DECIMAL(18,4),
	driver_pay				DECIMAL(18,4),
	shared_request			NVARCHAR(20),
	shared_match			NVARCHAR(20),
	access_a_ride			NVARCHAR(20),
	wav_request				NVARCHAR(20),
	wav_match				NVARCHAR(20),
);
GO

------------------------------------------------------
-- 4. License lookup
------------------------------------------------------
IF OBJECT_ID('bronze.td_license', 'U') IS NOT NULL
	DROP TABLE bronze.td_license;
GO

CREATE TABLE bronze.td_license (
	hvfhs_license_num		VARCHAR(10),
	app_company				NVARCHAR(20)
);
GO

------------------------------------------------------
-- 5. Taxi zones lookup
------------------------------------------------------
IF OBJECT_ID('bronze.td_taxi_zones', 'U') IS NOT NULL
	DROP TABLE bronze.td_taxi_zones;
GO

CREATE TABLE bronze.td_taxi_zones (
	location_id		INT,
	borough			NVARCHAR(30),
	zone			NVARCHAR(255),
	service_zone	NVARCHAR(20)
);
GO

------------------------------------------------------
-- 6. Weather table
------------------------------------------------------
IF OBJECT_ID('bronze.wd_weather', 'U') IS NOT NULL
	DROP TABLE bronze.wd_weather;
GO

CREATE TABLE bronze.wd_weather (
	station_id				NVARCHAR(50),
	date					NVARCHAR(50),
	latitude				NVARCHAR(50),
	longitude				NVARCHAR(50),
	elevation				NVARCHAR(50),
	station_name			NVARCHAR(50),
	temp_mean				NVARCHAR(50),
	temp_mean_att			NVARCHAR(50),
	dew_p					NVARCHAR(50),
	dew_p_att				NVARCHAR(50),
	sl_pressure				NVARCHAR(50),	
	sl_pressure_att			NVARCHAR(50),
	st_pressure				NVARCHAR(50),
	st_pressure_att			NVARCHAR(50),
	visibility				NVARCHAR(50),
	visibility_att			NVARCHAR(50),
	wind_s_mean				NVARCHAR(50),
	wind_s_mean_att			NVARCHAR(50),
	wind_s_max				NVARCHAR(50),
	wind_g_max				NVARCHAR(50),
	temp_max				NVARCHAR(50),
	temp_max_att			NVARCHAR(50),
	temp_min				NVARCHAR(50),
	temp_min_att			NVARCHAR(50),
	prcp_total				NVARCHAR(50),
	prcp_total_att			NVARCHAR(50),
	snow_dp					NVARCHAR(50),
	phenomena				NVARCHAR(50)
);
GO

------------------------------------------------------
-- 7. Events table
------------------------------------------------------
IF OBJECT_ID('bronze.ed_events', 'U') IS NOT NULL
	DROP TABLE bronze.ed_events;
GO

CREATE TABLE bronze.ed_events (
	event_id			NVARCHAR(MAX),
	event_name			NVARCHAR(MAX),
	start_datetime		NVARCHAR(MAX),
	end_datetime		NVARCHAR(MAX),
	event_agency		NVARCHAR(MAX),
	event_type			NVARCHAR(MAX),
	event_bourough		NVARCHAR(MAX),
	event_location		NVARCHAR(MAX),
	event_street_side	NVARCHAR(MAX),
	street_closure_type	NVARCHAR(MAX),
	community_board		NVARCHAR(MAX),
	police_precinct		NVARCHAR(MAX)
);
GO

------------------------------------------------------
-- 8. Holidays table
------------------------------------------------------
IF OBJECT_ID('bronze.hd_holidays', 'U') IS NOT NULL
	DROP TABLE bronze.hd_holidays
GO

CREATE TABLE bronze.hd_holidays (
	holiday_date DATE,
	holiday_name NVARCHAR(255)
)
GO









