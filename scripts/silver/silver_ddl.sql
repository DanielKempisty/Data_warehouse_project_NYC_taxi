/*
=============================================================
DDL script: Create silver layer tables
=============================================================
Script purpose:
	This script creates tables for silver layer in 'silver' schema.
	If tables exists, they are dropped and recreated.
	Run this query to (re)create the DDL structucre for silver layer.

WARNING:
	Running this script will drop all tables from 'silver' schema. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

------------------------------------------------------
-- 1. Create sequence for trip_id
------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'trip_id_seq')
DROP SEQUENCE silver.trip_id_seq

CREATE SEQUENCE silver.trip_id_seq
	AS BIGINT	
	START WITH 1
	INCREMENT BY 1;
GO

------------------------------------------------------
-- 2. Yellow taxi table
------------------------------------------------------
IF OBJECT_ID('silver.td_yellow_taxi', 'U') IS NOT NULL
	DROP TABLE silver.td_yellow_taxi;
GO

CREATE TABLE silver.td_yellow_taxi (
	trip_id					BIGINT NOT NULL,
	vendor_id				SMALLINT NOT NULL,
	pu_datetime				DATETIME2(0) NOT NULL,
	pu_date_key				BIGINT NOT NULL,
	do_datetime				DATETIME2(0) NOT NULL,
	do_date_key				BIGINT NOT NULL,
	pu_location_id			SMALLINT NOT NULL,
	do_location_id			SMALLINT NOT NULL,
	passenger_cnt			TINYINT NOT NULL,
	trip_distance			DECIMAL(8,2) NOT NULL,
	store_and_fwd			BIT NOT NULL,
	tariff_type_id			TINYINT NOT NULL,
	payment_type_id			TINYINT NOT NULL,
	fare_amount				DECIMAL(8,2) NOT NULL,
	tolls_amount			DECIMAL(8,2) NOT NULL,
	improvement_surcharge	DECIMAL(8,2) NOT NULL,
	congestion_surcharge	DECIMAL(8,2) NOT NULL,
	airport_fee				DECIMAL(8,2) NOT NULL,
	mta_tax					DECIMAL(8,2) NOT NULL,
	extra					DECIMAL(8,2) NOT NULL,
	tip_amount				DECIMAL(8,2) NOT NULL,
	total_amount			DECIMAL(8,2) NOT NULL,
	reject_id				TINYINT NOT NULL
);
GO

------------------------------------------------------
-- 3. Green taxi table
------------------------------------------------------
IF OBJECT_ID('silver.td_green_taxi', 'U') IS NOT NULL
	DROP TABLE silver.td_green_taxi;
GO

CREATE TABLE silver.td_green_taxi (
	trip_id					BIGINT NOT NULL,
	vendor_id				SMALLINT NOT NULL,
	pu_datetime				DATETIME2(0) NOT NULL,
	pu_date_key				BIGINT NOT NULL,
	do_datetime				DATETIME2(0) NOT NULL,
	do_date_key				BIGINT NOT NULL,
	pu_location_id			SMALLINT NOT NULL,
	do_location_id			SMALLINT NOT NULL,
	passenger_cnt			TINYINT NOT NULL,
	trip_distance			DECIMAL(8,2) NOT NULL,
	trip_type_id			TINYINT NOT NULL,
	store_and_fwd			BIT NOT NULL,
	tariff_type_id			TINYINT NOT NULL,
	payment_type_id			TINYINT NOT NULL,
	fare_amount				DECIMAL(8,2) NOT NULL,
	tolls_amount			DECIMAL(8,2) NOT NULL,
	improvement_surcharge	DECIMAL(8,2) NOT NULL,
	congestion_surcharge	DECIMAL(8,2) NOT NULL,
	ehail_fee				DECIMAL(8,2) NOT NULL,
	mta_tax					DECIMAL(8,2) NOT NULL,
	extra					DECIMAL(8,2) NOT NULL,
	tip_amount				DECIMAL(8,2) NOT NULL,
	total_amount			DECIMAL(8,2) NOT NULL,
	reject_id				TINYINT NOT NULL
);
GO

------------------------------------------------------
-- 4. For-hire vehicle table
------------------------------------------------------
IF OBJECT_ID('silver.td_for_hire', 'U') IS NOT NULL
	DROP TABLE silver.td_for_hire;
GO

CREATE TABLE silver.td_for_hire (
	trip_id					BIGINT NOT NULL,
	hvfhs_license_num		CHAR(6) NOT NULL,
	dispatch_base_num		CHAR(6) NULL,
	originate_base_num		CHAR(6) NULL,
	request_datetime		DATETIME2(0) NULL,
	on_scene_datetime		DATETIME2(0) NULL,
	pu_datetime				DATETIME2(0) NOT NULL,
	pu_date_key				BIGINT NOT NULL,
	do_datetime				DATETIME2(0) NOT NULL,
	do_date_key				BIGINT NOT NULL,
	pu_location_id			SMALLINT NOT NULL,
	do_location_id			SMALLINT NOT NULL,
	trip_distance			DECIMAL(8,2) NOT NULL,
	shared_request			BIT NOT NULL,
	shared_match			BIT NOT NULL,
	access_a_ride			BIT NOT NULL,
	wav_request				BIT NOT NULL,
	wav_match				BIT NOT NULL,
	base_passenger_fee		DECIMAL(8,2) NOT NULL,
	driver_pay				DECIMAL(8,2) NOT NULL,
	tolls_amount			DECIMAL(8,2) NOT NULL,
	congestion_surcharge	DECIMAL(8,2) NOT NULL,
	airport_fee				DECIMAL(8,2) NOT NULL,
	bcf_fee					DECIMAL(8,2) NOT NULL,
	sales_tax				DECIMAL(8,2) NOT NULL,
	tip_amount				DECIMAL(8,2) NOT NULL,
	total_amount			DECIMAL(8,2) NOT NULL,
	reject_id				TINYINT NOT NULL
);
GO

------------------------------------------------------
-- 5. License look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_license', 'U') IS NOT NULL
	DROP TABLE silver.td_license;
GO

CREATE TABLE silver.td_license (
	hvfhs_license_num		CHAR(6) NOT NULL,
	app_company				NVARCHAR(20) NOT NULL
);
GO

------------------------------------------------------
-- 6. Taxi zones look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_taxi_zones', 'U') IS NOT NULL
	DROP TABLE silver.td_taxi_zones;
GO

CREATE TABLE silver.td_taxi_zones (
	location_id		SMALLINT NOT NULL,
	borough_id		TINYINT NOT NULL,
	zone			NVARCHAR(255) NOT NULL,
	service_zone	NVARCHAR(20) NOT NULL,
	is_cbd			BIT NOT NULL,
	is_airport		BIT NOT NULL
);
GO

------------------------------------------------------
-- 7. Vendor look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_vendor', 'U') IS NOT NULL
	DROP TABLE silver.td_vendor;
GO

CREATE TABLE silver.td_vendor (
	vendor_id		SMALLINT NOT NULL,
	vendor_name		NVARCHAR(50) NOT NULL
);
GO

------------------------------------------------------
-- 8. Tariff type look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_tariff_type', 'U') IS NOT NULL
	DROP TABLE silver.td_tariff_type;
GO

CREATE TABLE silver.td_tariff_type (
	tariff_type_id		TINYINT NOT NULL,
	tariff_type			NVARCHAR(30) NOT NULL
);
GO

------------------------------------------------------
-- 9. Trip type look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_trip_type', 'U') IS NOT NULL
	DROP TABLE silver.td_trip_type;
GO

CREATE TABLE silver.td_trip_type (
	trip_type_id		TINYINT NOT NULL,
	trip_type			NVARCHAR(20) NOT NULL
);
GO

------------------------------------------------------
-- 10. Payment type look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_payment_type', 'U') IS NOT NULL
	DROP TABLE silver.td_payment_type;
GO

CREATE TABLE silver.td_payment_type (
	payment_type_id			TINYINT NOT NULL,
	payment_type			NVARCHAR(20) NOT NULL
);
GO

------------------------------------------------------
-- 11. Weather table
------------------------------------------------------
IF OBJECT_ID('silver.wd_weather', 'U') IS NOT NULL
	DROP TABLE silver.wd_weather;
GO

CREATE TABLE silver.wd_weather (
	station_id					BIGINT NOT NULL,
	station_name				NVARCHAR(255) NOT NULL,
	weather_date				DATE NOT NULL,
	weather_date_key			BIGINT NOT NULL,
	temp_mean					DECIMAL(7,2) NULL,
	temp_max					DECIMAL(7,2) NULL,
	temp_min					DECIMAL(7,2) NULL,
	prcp_total					DECIMAL(7,2) NULL,
	visibility					DECIMAL(7,2) NULL,
	snow_dp						DECIMAL(7,2) NULL,
	wind_s_mean					DECIMAL(7,2) NULL,
	wind_s_max					DECIMAL(7,2) NULL,
	wind_g_max					DECIMAL(7,2) NULL,
	dew_p						DECIMAL(7,2) NULL,
	sl_pressure					DECIMAL(7,2) NULL,
	st_pressure					DECIMAL(7,2) NULL,
	fog							BIT NOT NULL,
	rain_or_drizzle				BIT NOT NULL,
	snow_or_ice_pellets			BIT NOT NULL,
	hail						BIT NOT NULL,
	thunder						BIT NOT NULL,
	tornado_or_funnel_cloud		BIT NOT NULL
);
GO

------------------------------------------------------
-- 12. Events table
------------------------------------------------------
IF OBJECT_ID('silver.ed_events', 'U') IS NOT NULL
	DROP TABLE silver.ed_events;
GO

CREATE TABLE silver.ed_events (
	event_occurance_id			BIGINT IDENTITY(1,1) NOT NULL,
	event_id					INT NOT NULL,
	event_name					NVARCHAR(255) NULL,
	start_datetime				DATETIME2(0) NOT NULL,
	start_date_key				BIGINT NOT NULL,
	end_datetime				DATETIME2(0) NOT NULL,
	end_date_key				BIGINT NOT NULL,
	agency_id					TINYINT NOT NULL,
	event_type_id				TINYINT NOT NULL,
	borough_id					TINYINT NOT NULL,
	street_closure_type_id		TINYINT NOT NULL,
	reject_id					TINYINT NOT NULL
);
GO

------------------------------------------------------
-- 13. Date look-up
------------------------------------------------------
IF OBJECT_ID('silver.hd_date', 'U') IS NOT NULL
	DROP TABLE silver.hd_date
GO

CREATE TABLE silver.hd_date (
	date_key		BIGINT NOT NULL,
	full_date		DATE NULL,
	quarter			TINYINT NULL,
	month			TINYINT NULL,
	day				TINYINT NULL,
	is_weekend		BIT NULL,
	is_holiday		BIT NULL,
	holiday_name	NVARCHAR(255) NULL
)
GO

------------------------------------------------------
-- 14. Borough look-up
------------------------------------------------------
IF OBJECT_ID('silver.borough', 'U') IS NOT NULL
	DROP TABLE silver.borough
GO

CREATE TABLE silver.borough (
	borough_id		TINYINT NOT NULL,
	borough_name	NVARCHAR(20) NOT NULL,
	is_airport		TINYINT NOT NULL
)
GO

------------------------------------------------------
-- 15. Reject_id look-up
------------------------------------------------------
IF OBJECT_ID('silver.td_reject', 'U') IS NOT NULL
	DROP TABLE silver.td_reject;

CREATE TABLE silver.td_reject (
	reject_id			TINYINT NOT NULL,
	reject_description	NVARCHAR(255) NOT NULL
);
GO

------------------------------------------------------
-- 16. Quality conditions
------------------------------------------------------
IF OBJECT_ID('silver.qc_conditions', 'U') IS NOT NULL
		DROP TABLE silver.qc_conditions;

	CREATE TABLE silver.qc_conditions (
		table_name		SYSNAME NOT NULL,
		condition		NVARCHAR(255) NOT NULL,
		error_id		SMALLINT IDENTITY(101,1) NOT NULL,
		error_message	NVARCHAR(255) NOT NULL
	);

------------------------------------------------------
-- 17. Event agency look-up
------------------------------------------------------
IF OBJECT_ID('silver.ed_event_agency', 'U') IS NOT NULL
		DROP TABLE silver.ed_event_agency;

	CREATE TABLE silver.ed_event_agency (
		agency_id		TINYINT IDENTITY(1,1) NOT NULL,
		agency_name		NVARCHAR(255) NOT NULL
	);

------------------------------------------------------
-- 18. Event type look-up
------------------------------------------------------
IF OBJECT_ID('silver.ed_event_type', 'U') IS NOT NULL
		DROP TABLE silver.ed_event_type;

	CREATE TABLE silver.ed_event_type (
		event_type_id	TINYINT IDENTITY(1,1) NOT NULL,
		event_type		NVARCHAR(255) NOT NULL
	);

------------------------------------------------------
-- 19. Street closure type look-up
------------------------------------------------------
IF OBJECT_ID('silver.ed_street_closure_type', 'U') IS NOT NULL
		DROP TABLE silver.ed_street_closure_type;

	CREATE TABLE silver.ed_street_closure_type (
		street_closure_type_id		TINYINT IDENTITY(1,1) NOT NULL,
		street_closure_type			NVARCHAR(255) NULL
	);



