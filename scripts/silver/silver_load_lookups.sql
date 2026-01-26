/*
=============================================================
Stored Procedure: Load look-up tables to the silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate look-up tables from silver layer
	2. tranform and clean data from bronze layer or create new data
	3. load look-up tables silver layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_look_up_data_to_silver

WARNING:
	Running this procedure will truncate all look-up tables in silver layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_look_up_data_to_silver AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE 
		@start_time DATETIME2(0), 
		@end_time DATETIME2(0), 
		@total_start_time DATETIME2(0),
		@total_end_time DATETIME2(0),
		@rows_count INT,
		@current_source NVARCHAR(128),
		@current_destination NVARCHAR(128);

	BEGIN TRY
		
		BEGIN TRAN;

		SET @total_start_time = SYSDATETIME();

		------------------------------------------------------
		-- 1. Taxi zones
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'bronze.td_taxi_zones';
		SET @current_destination= 'silver.td_taxi_zones';

		PRINT('>> STEP 1/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_taxi_zones;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 2/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_taxi_zones(
			location_id,
			borough_id,
			zone,
			service_zone,
			is_cbd,
			is_airport
		)
		SELECT
			location_id
			,CASE
				WHEN location_id = 132 THEN 7
				WHEN location_id = 138 THEN 8
				WHEN REPLACE(TRIM(borough), '"', '') = 'Bronx' THEN 1
				WHEN REPLACE(TRIM(borough), '"', '') = 'Brooklyn' THEN 2
				WHEN REPLACE(TRIM(borough), '"', '') = 'Manhattan' THEN 3
				WHEN REPLACE(TRIM(borough), '"', '') = 'Queens' THEN 4
				WHEN REPLACE(TRIM(borough), '"', '') = 'Staten Island' THEN 5
				WHEN REPLACE(TRIM(borough), '"', '') = 'EWR' THEN 6
				WHEN REPLACE(TRIM(borough), '"', '') = 'N/A' THEN 9
				WHEN REPLACE(TRIM(borough), '"', '') = 'Unknown' THEN 10
			END AS borough_id
			,IIF(zone = '"N/A"', 'Unknown', REPLACE(TRIM(zone), '"', '')) AS zone
			,CASE
				WHEN location_id = 132 THEN 'JFK'
				WHEN location_id = 138 THEN 'LaGuardia'
				WHEN location_id = 264 THEN 'Unknown'
				WHEN location_id = 265 THEN 'Outside of NYC'
				ELSE REPLACE(TRIM(service_zone), '"', '') 
			END AS service_zone
			,IIF(location_id IN (50, 48, 163, 230, 161, 162, 229, 233, 170, 164, 100, 246, 68, 186, 90, 234, 107, 137, 224, 158, 249, 113, 114, 79, 4, 125, 211, 144, 148, 232, 231, 45, 209, 87, 261, 13, 88, 12), 1, 0) AS is_cbd
			,IIF(location_id IN (1, 132, 138), 1, 0) AS is_airport
		FROM bronze.td_taxi_zones;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_taxi_zones;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 2. Borough look-up
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.borough';

		PRINT('>> STEP 3/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.borough;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 4/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.borough(
			borough_id,
			borough_name,
			is_airport
		)
		VALUES 
			(1, 'Bronx', 0),
			(2, 'Brooklyn', 0),
			(3, 'Manhattan', 0),
			(4, 'Queens', 0),
			(5, 'Staten Island', 0),
			(6, 'EWR', 1),
			(7, 'JFK', 1),
			(8, 'LaGuardia', 1),
			(9, 'Outside of NYC', 0),
			(10, 'Unknown', 0);

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.borough;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 3. Reject look-up
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.td_reject';

		PRINT('>> STEP 5/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_reject;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 6/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_reject(
			reject_id,
			reject_description
		)
		VALUES 
			(0, 'validate data'),
			(1, 'trip distance lower or equal zero'),
			(2, 'total amount lower or equal zero'),
			(3, 'drop off time earlier or equal pick up time '),
			(4, 'total amount not equal to sum of its components'),
			(5, 'unknown vendor id'),
			(6, 'pick up or drop off time not in 2024 year'),
			(7, 'trip longer than 6 hours'),
			(8, 'average speed higher than 150 km/h'),
			(9, 'one of amount columns lower than 0, amount columns: base_passenger_fee, driver_pay, tolls_amount, congestion_surcharge, airport_fee, bcf_fee, sales_tax, tip_amount'),
			(10, 'start of event earlier than the end'),
			(11, 'start and end of event not in 2024 year');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_reject;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 4. Quality check conditions
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.qc_conditions';

		PRINT('>> STEP 7/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.qc_conditions;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 8/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.qc_conditions
				(table_name, condition, error_message)
		VALUES
			('td_yellow_taxi', 'pu_datetime >= do_datetime', 'VALUES WITH pu_datetime >= do_datetime'),
			('td_yellow_taxi', 'passenger_cnt > 9', 'VALUES > 9 IN COLUMN passenger_cnt'),
			('td_yellow_taxi', 'total_amount <> (tip_amount + extra + mta_tax + airport_fee + congestion_surcharge + improvement_surcharge + tolls_amount + fare_amount)', 'COLUMN total_amount not equal to its components'),
			('td_yellow_taxi', 'trip_id <= 0', 'VALUES <= 0 IN COLUMN trip_id'),
			('td_yellow_taxi', 'vendor_id NOT IN (1, 2)', 'VALUES NOT IN (1, 2) IN COLUMN vendor_id'),
			('td_yellow_taxi', 'pu_location_id <= 0', 'VALUES <= 0 IN COLUMN pu_location_id'),
			('td_yellow_taxi', 'do_location_id <= 0', 'VALUES <= 0 IN COLUMN do_location_id'),
			('td_yellow_taxi', 'passenger_cnt <= 0', 'VALUES <= 0 IN COLUMN passenger_cnt'),
			('td_yellow_taxi', 'trip_distance <= 0', 'VALUES <= 0 IN COLUMN trip_distance'),
			('td_yellow_taxi', 'tariff_type_id <= 0', 'VALUES <= 0 IN COLUMN tariff_type_id'),
			('td_yellow_taxi', 'payment_type_id <= 0', 'VALUES <= 0 IN COLUMN payment_type_id'),
			('td_yellow_taxi', 'fare_amount < 0', 'VALUES < 0 IN COLUMN fare_amount'),
			('td_yellow_taxi', 'tolls_amount < 0', 'VALUES < 0 IN COLUMN tolls_amount'),
			('td_yellow_taxi', 'improvement_surcharge < 0', 'VALUES < 0 IN COLUMN improvement_surcharge'),
			('td_yellow_taxi', 'congestion_surcharge < 0', 'VALUES < 0 IN COLUMN congestion_surcharge'),
			('td_yellow_taxi', 'mta_tax < 0', 'VALUES < 0 IN COLUMN mta_tax'),
			('td_yellow_taxi', 'extra < 0', 'VALUES < 0 IN COLUMN extra'),
			('td_yellow_taxi', 'tip_amount < 0', 'VALUES < 0 IN COLUMN tip_amount'),
			('td_yellow_taxi', 'total_amount < 0', 'VALUES < 0 IN COLUMN total_amount'),
			('td_yellow_taxi', 'airport_fee < 0', 'VALUES < 0 IN COLUMN airport_fee'),
			('td_yellow_taxi', 'DATEDIFF(HOUR, pu_datetime, do_datetime) > 6', 'TRIP DURATION LONGER THAN 6H'),
			('td_yellow_taxi', 'YEAR(pu_datetime) != 2024', 'PICK UP DATE NOT IN 2024'),
			('td_yellow_taxi', 'YEAR(do_datetime) != 2024', 'DROP OFF DATE NOT IN 2024'),
			('td_yellow_taxi', 'IIF(DATEDIFF(SECOND, pu_datetime, do_datetime) > 0, trip_distance / CAST(DATEDIFF(SECOND, pu_datetime, do_datetime) AS DECIMAL(10, 1)) * 3600, 0) >= 150', 'AVERAGE SPEED HIGHER THAN 150 KM/H'),

			('td_green_taxi', 'pu_datetime >= do_datetime', 'VALUES WITH pu_datetime >= do_datetime'),
			('td_green_taxi', 'passenger_cnt > 9', 'VALUES > 9 IN COLUMN passenger_cnt'),
			('td_green_taxi', 'total_amount <> (tip_amount + extra + mta_tax + ehail_fee + congestion_surcharge + improvement_surcharge + tolls_amount + fare_amount)', 'COLUMN total_amount not equal to its components'),
			('td_green_taxi', 'trip_id <= 0', 'VALUES <= 0 IN COLUMN trip_id'),
			('td_green_taxi', 'vendor_id NOT IN (1, 2)', 'VALUES NOT IN (1, 2) IN COLUMN vendor_id'),
			('td_green_taxi', 'trip_type_id <= 0', 'VALUES <= 0 IN COLUMN trip_type_id'),
			('td_green_taxi', 'pu_location_id <= 0', 'VALUES <= 0 IN COLUMN pu_location_id'),
			('td_green_taxi', 'do_location_id <= 0', 'VALUES <= 0 IN COLUMN do_location_id'),
			('td_green_taxi', 'passenger_cnt <= 0', 'VALUES <= 0 IN COLUMN passenger_cnt'),
			('td_green_taxi', 'trip_distance <= 0', 'VALUES <= 0 IN COLUMN trip_distance'),
			('td_green_taxi', 'tariff_type_id <= 0', 'VALUES <= 0 IN COLUMN tariff_type_id'),
			('td_green_taxi', 'payment_type_id <= 0', 'VALUES <= 0 IN COLUMN payment_type_id'),
			('td_green_taxi', 'fare_amount < 0', 'VALUES < 0 IN COLUMN fare_amount'),
			('td_green_taxi', 'tolls_amount < 0', 'VALUES < 0 IN COLUMN tolls_amount'),
			('td_green_taxi', 'improvement_surcharge < 0', 'VALUES < 0 IN COLUMN improvement_surcharge'),
			('td_green_taxi', 'congestion_surcharge < 0', 'VALUES < 0 IN COLUMN congestion_surcharge'),
			('td_green_taxi', 'mta_tax < 0', 'VALUES < 0 IN COLUMN mta_tax'),
			('td_green_taxi', 'extra < 0', 'VALUES < 0 IN COLUMN extra'),
			('td_green_taxi', 'tip_amount < 0', 'VALUES < 0 IN COLUMN tip_amount'),
			('td_green_taxi', 'total_amount < 0', 'VALUES < 0 IN COLUMN total_amount'),
			('td_green_taxi', 'ehail_fee < 0', 'VALUES < 0 IN COLUMN ehail_fee'),
			('td_green_taxi', 'DATEDIFF(HOUR, pu_datetime, do_datetime) > 6', 'TRIP DURATION LONGER THAN 6H'),
			('td_green_taxi', 'YEAR(pu_datetime) != 2024', 'PICK UP DATE NOT IN 2024'),
			('td_green_taxi', 'YEAR(do_datetime) != 2024', 'DROP OFF DATE NOT IN 2024'),
			('td_green_taxi', 'IIF(DATEDIFF(SECOND, pu_datetime, do_datetime) > 0, trip_distance / CAST(DATEDIFF(SECOND, pu_datetime, do_datetime) AS DECIMAL(10, 1)) * 3600, 0) >= 150', 'AVERAGE SPEED HIGHER THAN 150 KM/H'),
			
			('td_for_hire', 'pu_datetime >= do_datetime', 'VALUES WITH pu_datetime >= do_datetime'),
			('td_for_hire', 'total_amount <> (base_passenger_fee + tolls_amount + congestion_surcharge + airport_fee + bcf_fee + sales_tax + tip_amount)', 'COLUMN total_amount not equal to its components'),
			('td_for_hire', 'trip_id <= 0', 'VALUES <= 0 IN COLUMN trip_id'),
			('td_for_hire', 'pu_location_id <= 0', 'VALUES <= 0 IN COLUMN pu_location_id'),
			('td_for_hire', 'do_location_id <= 0', 'VALUES <= 0 IN COLUMN do_location_id'),
			('td_for_hire', 'trip_distance <= 0', 'VALUES <= 0 IN COLUMN trip_distance'),
			('td_for_hire', 'base_passenger_fee < 0', 'VALUES < 0 IN COLUMN base_passenger_fee'),
			('td_for_hire', 'driver_pay < 0', 'VALUES < 0 IN COLUMN driver_pay'),
			('td_for_hire', 'tolls_amount < 0', 'VALUES < 0 IN COLUMN tolls_amount'),
			('td_for_hire', 'congestion_surcharge < 0', 'VALUES < 0 IN COLUMN congestion_surcharge'),
			('td_for_hire', 'airport_fee < 0', 'VALUES < 0 IN COLUMN airport_fee'),
			('td_for_hire', 'bcf_fee < 0', 'VALUES < 0 IN COLUMN bcf_fee'),
			('td_for_hire', 'sales_tax < 0', 'VALUES < 0 IN COLUMN sales_tax'),
			('td_for_hire', 'tip_amount < 0', 'VALUES < 0 IN COLUMN tip_amount'),
			('td_for_hire', 'total_amount < 0', 'VALUES < 0 IN COLUMN total_amount'),
			('td_for_hire', 'DATEDIFF(HOUR, pu_datetime, do_datetime) > 6', 'TRIP DURATION LONGER THAN 6H'),
			('td_for_hire', 'YEAR(pu_datetime) != 2024', 'PICK UP DATE NOT IN 2024'),
			('td_for_hire', 'YEAR(do_datetime) != 2024', 'DROP OFF DATE NOT IN 2024'),
			('td_for_hire', 'IIF(DATEDIFF(SECOND, pu_datetime, do_datetime) > 0, trip_distance / CAST(DATEDIFF(SECOND, pu_datetime, do_datetime) AS DECIMAL(10, 1)) * 3600, 0) >= 150', 'AVERAGE SPEED HIGHER THAN 150 KM/H'),
			
			('td_ed_events', 'start_datetime >= end_datetime', 'VALUES WITH start_datetime >= end_datetime'),
			('td_ed_events', 'YEAR(start_datetime) != 2024 AND YEAR(end_datetime) != 2024', 'COLUMNS start_datetime AND end_datetime NOT IN 2024'),
			('td_ed_events', 'event_occurance_id < 0', 'VALUES < 0 IN COLUMN event_occurance_id'),
			('td_ed_events', 'event_id < 0', 'VALUES < 0 IN COLUMN event_id'),
			('td_ed_events', 'agency_id < 0', 'VALUES < 0 IN COLUMN agency_id'),
			('td_ed_events', 'event_type_id < 0', 'VALUES < 0 IN COLUMN event_type_id'),
			('td_ed_events', 'borough_id < 0', 'VALUES < 0 IN COLUMN borough_id'),
			('td_ed_events', 'street_closure_type_id < 0', 'VALUES < 0 IN COLUMN street_closure_type_id');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.qc_conditions;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 5. Vendor look-up
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.td_vendor';


		PRINT('>> STEP 9/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_vendor;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 10/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_vendor
				(vendor_id, vendor_name)
		VALUES
			(1, 'Creative Mobile Technologies'),
			(2, 'VerfiFone'),
			(-1, 'Unknown')

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_vendor;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 6. Trip type lookup
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.td_trip_type';

		PRINT('>> STEP 11/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_trip_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 12/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_trip_type
				(trip_type_id, trip_type)
		VALUES
			(1, 'street-hail'),
			(2, 'dispatch');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_trip_type;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 7. Tariff type lookup
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.td_tariff_type';

		PRINT('>> STEP 13/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_tariff_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 14/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_tariff_type
				(tariff_type_id, tariff_type)
		VALUES
			(1, 'standard rate'),
			(2, 'JFK'),
			(3, 'Newark'),
			(4, 'Nassau or Westchester'),
			(5, 'negotiated fare'),
			(6, 'group ride');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_tariff_type;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 8. Payment type lookup
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'silver.td_payment_type';

		PRINT('>> STEP 15/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_payment_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 16/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_payment_type
				(payment_type_id, payment_type)
		VALUES
			(1, 'credit card'),
			(2, 'cash'),
			(3, 'no charge'),
			(4, 'dispute'),
			(5, 'unknown'),
			(6, 'voided trip');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_payment_type;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 9. License
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'bronze.td_license';
		SET @current_destination= 'silver.td_license';

		PRINT('>> STEP 17/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.td_license;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 18/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.td_license
				(hvfhs_license_num, app_company)
		SELECT
			hvfhs_license_num,
			app_company
		FROM bronze.td_license;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.td_license;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 10. Event agency look-up
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'bronze.ed_events';
		SET @current_destination= 'silver.ed_event_agency';

		PRINT('>> STEP 19/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.ed_event_agency;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 20/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.ed_event_agency
				(agency_name)
		SELECT DISTINCT
			REPLACE(TRIM(event_agency), '"', '')
		FROM bronze.ed_events;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.ed_event_agency;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 11. Event type look-up
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'bronze.ed_events';
		SET @current_destination= 'silver.ed_event_type';

		PRINT('>> STEP 21/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.ed_event_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 22/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.ed_event_type
				(event_type)
		SELECT DISTINCT
			REPLACE(TRIM(event_type), '"', '')
		FROM bronze.ed_events;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.ed_event_type;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 12. Street closure type look-up
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'bronze.ed_events';
		SET @current_destination= 'silver.ed_street_closure_type';

		PRINT('>> STEP 23/24: Truncating table ' + @current_destination);

		TRUNCATE TABLE silver.ed_street_closure_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 24/24: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO silver.ed_street_closure_type
				(street_closure_type)
		SELECT DISTINCT
			IIF(REPLACE(TRIM(street_closure_type), '"', '')	= '',
				'none',
				REPLACE(TRIM(street_closure_type), '"', ''))
		FROM bronze.ed_events;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM silver.ed_street_closure_type;

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), @rows_count, 
			@rows_count, @rows_count, 0, DATEDIFF(SECOND, @start_time, @end_time), 'success'
		);

		------------------------------------------------------
		-- 13. End stats & messages
		------------------------------------------------------

		SET @total_end_time = SYSDATETIME();

		PRINT('Loading lookup tables completed!');
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @total_start_time, @total_end_time) AS VARCHAR) + 's');
		PRINT('');

		SET NOCOUNT OFF;

		COMMIT;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK;

		SET @end_time =  SYSDATETIME();

		PRINT('');
		PRINT('ERROR HAS OCCURED');
		PRINT('');
		PRINT('Error message: ' + ERROR_MESSAGE());
		PRINT('Error number: ' + CAST(ERROR_NUMBER() AS VARCHAR));
		PRINT('Error line: ' + CAST(ERROR_LINE() AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (batch_start_time, batch_end_time, source, destination_table, executed_by, rows_loaded, 
									valid_rows, non_valid_rows, non_valid_percent,duration_seconds, status, error_message
									)
		VALUES(
			@start_time, @end_time, @current_source, @current_destination, ORIGINAL_LOGIN(), 0, 
			0, 0, 0, DATEDIFF(SECOND, @start_time, @end_time), 'fail', ERROR_MESSAGE()
		);

		SET NOCOUNT OFF;

		THROW;

	END CATCH
END