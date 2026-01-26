/*
=============================================================
Stored Procedure: Load fact_trips tabel to the gold layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate fact_trips table from gold layer
	2. tranform and clean data from silver layer with trips data
	3. load trips data from silver to gold layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_trips_to_gold

WARNING:
	Running this procedure will truncate fact_trips table in gold layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_trips_to_gold AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE 
		@start_time DATETIME2(0), 
		@end_time DATETIME2(0), 
		@start_time_total DATETIME2(0), 
		@end_time_total DATETIME2(0), 
		@rows_count_bef BIGINT, 
		@rows_count_aft BIGINT, 
		@rows_loaded BIGINT,
		@current_source NVARCHAR(128);

	BEGIN TRY

		BEGIN TRAN;

		SET @start_time_total = SYSDATETIME();

		------------------------------------------------------
		-- 1. Truncate existing table
		------------------------------------------------------

		PRINT('>> STEP 1/4: Truncating table gold.fact_trips');

		TRUNCATE TABLE gold.fact_trips;

		PRINT('gold.fact_trips table has been truncated');

		------------------------------------------------------
		-- 2. Insert - yellow taxi
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/4: Transform and load yellow taxi data into gold.fact_trips');

		SET @current_source = 'silver.td_yellow_taxi';

		SET @start_time = SYSDATETIME();
		SELECT @rows_count_bef = COUNT(*) FROM gold.fact_trips;

		INSERT INTO gold.fact_trips(
			taxi_type_id,		
			pu_date_key,			
			pu_hour,				
			do_date_key,			
			do_hour,				
			trip_time,			
			pu_borough_id,		
			do_borough_id,		
			trip_distance,		
			distance_bucket_id,	
			fare_amount,			
			tip_amount,			
			is_tip,				
			tolls_amount,		
			improvement_surcharge,	
			congestion_surcharge,
			airport_fee,			
			mta_tax,				
			extra,				
			ehail_fee,			
			bcf_fee,				
			sales_tax,			
			total_amount,		
			trips_cnt)
		SELECT
			1																AS taxi_type_id,
			yt.pu_date_key													AS pu_date_key,
			ti_pu.time_interval												AS pu_hour,
			yt.do_date_key													AS do_date_key,
			ti_do.time_interval												AS do_hour,
			SUM(DATEDIFF(SECOND, pu_datetime, do_datetime))					AS trip_time,
			tz_pu.borough_id												AS pu_borough_id,
			tz_do.borough_id												AS do_borough_id,
			SUM(yt.trip_distance)											AS trip_distance,
			CASE
				WHEN yt.trip_distance <= 2 THEN 1
				WHEN yt.trip_distance <= 5 THEN 2
				WHEN yt.trip_distance <= 8 THEN 3
				WHEN yt.trip_distance <= 12 THEN 4
				WHEN yt.trip_distance <= 20 THEN 5
				WHEN yt.trip_distance > 20 THEN 6								
			END																AS distance_bucket_id,
			SUM(yt.fare_amount)												AS fare_amount,
			SUM(yt.tip_amount)												AS tip_amount,
			IIF(yt.tip_amount > 0, 1, 0)									AS is_tip,
			SUM(yt.tolls_amount)											AS tolls_amount,
			SUM(yt.improvement_surcharge)									AS improvement_surcharge,
			SUM(yt.congestion_surcharge)									AS congestion_surcharge,
			SUM(yt.airport_fee)												AS airport_fee,
			SUM(yt.mta_tax)													AS mta_tax,
			SUM(yt.extra)													AS extra,
			0																AS ehail_fee,
			0																AS bcf_fee,
			0																AS sales_tax,
			SUM(yt.total_amount)											AS total_amount,
			COUNT(yt.trip_id)												AS trips_cnt
		FROM silver.td_yellow_taxi yt
			INNER JOIN silver.td_taxi_zones tz_pu
				ON tz_pu.location_id = yt.pu_location_id
			INNER JOIN silver.td_taxi_zones tz_do
				ON tz_do.location_id = yt.do_location_id
			OUTER APPLY silver.time_interval(yt.pu_datetime) ti_pu
			OUTER APPLY silver.time_interval(yt.do_datetime) ti_do
			WHERE
				yt.reject_id = 0
			GROUP BY
				yt.pu_date_key,		
				ti_pu.time_interval	,
				yt.do_date_key,
				ti_do.time_interval,
				tz_pu.borough_id,
				tz_do.borough_id,
				CASE
					WHEN yt.trip_distance <= 2 THEN 1
					WHEN yt.trip_distance <= 5 THEN 2
					WHEN yt.trip_distance <= 8 THEN 3
					WHEN yt.trip_distance <= 12 THEN 4
					WHEN yt.trip_distance <= 20 THEN 5
					WHEN yt.trip_distance > 20 THEN 6								
				END,
				IIF(yt.tip_amount > 0, 1, 0);


		SELECT @rows_count_aft = COUNT(*) FROM gold.fact_trips;
		SET @rows_loaded = @rows_count_aft - @rows_count_bef;

		SET @end_time =  SYSDATETIME();

		PRINT('Loaded records: ' + CAST((CAST(@rows_loaded AS INT)) AS VARCHAR));

		INSERT INTO etl.log_batch (
			batch_start_time, 
			batch_end_time, 
			source, 
			destination_table, 
			executed_by, 
			rows_loaded, 
			valid_rows, 
			non_valid_rows, 
			non_valid_percent, 
			duration_seconds, 
			status)
		VALUES(
			@start_time,
			@end_time,
			@current_source,
			'gold.fact_trips',
			ORIGINAL_LOGIN(),
			@rows_loaded,
			@rows_loaded,
			0,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);

		------------------------------------------------------
		-- 3. Insert - green taxi
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 3/4: Transform and load green taxi data into gold.fact_trips');

		SET @current_source = 'silver.td_green_taxi';

		SET @start_time = SYSDATETIME();
		SELECT @rows_count_bef = COUNT(*) FROM gold.fact_trips;

		INSERT INTO gold.fact_trips(
			taxi_type_id,		
			pu_date_key,			
			pu_hour,				
			do_date_key,			
			do_hour,				
			trip_time,			
			pu_borough_id,		
			do_borough_id,		
			trip_distance,		
			distance_bucket_id,	
			fare_amount,			
			tip_amount,			
			is_tip,				
			tolls_amount,		
			improvement_surcharge,	
			congestion_surcharge,
			airport_fee,			
			mta_tax,				
			extra,				
			ehail_fee,			
			bcf_fee,				
			sales_tax,			
			total_amount,		
			trips_cnt)
		SELECT
			2																	AS taxi_type_id,
			gt.pu_date_key														AS pu_date_key,
			ti_pu.time_interval													AS pu_hour,
			gt.do_date_key														AS do_date_key,
			ti_do.time_interval													AS do_hour,
			SUM(DATEDIFF(SECOND, pu_datetime, do_datetime))						AS trip_time,
			tz_pu.borough_id													AS pu_borough_id,
			tz_do.borough_id													AS do_borough_id,
			SUM(gt.trip_distance)												AS trip_distance,
			CASE
				WHEN gt.trip_distance <= 2 THEN 1
				WHEN gt.trip_distance <= 5 THEN 2
				WHEN gt.trip_distance <= 8 THEN 3
				WHEN gt.trip_distance <= 12 THEN 4
				WHEN gt.trip_distance <= 20 THEN 5
				WHEN gt.trip_distance > 20 THEN 6								
			END																	AS distance_bucket_id,
			SUM(gt.fare_amount)													AS fare_amount,
			SUM(gt.tip_amount)													AS tip_amount,
			IIF(gt.tip_amount > 0, 1, 0)										AS is_tip,
			SUM(gt.tolls_amount)												AS tolls_amount,		
			SUM(gt.improvement_surcharge)										AS improvement_surcharge,	
			SUM(gt.congestion_surcharge)										AS congestion_surcharge,
			0																	AS airport_fee,			
			SUM(gt.mta_tax)														AS mta_tax,				
			SUM(gt.extra)														AS extra,				
			SUM(gt.ehail_fee)													AS ehail_fee,			
			0																	AS bcf_fee,				
			0																	AS sales_tax,	
			SUM(gt.total_amount)												AS total_amount,
			COUNT(gt.trip_id)													AS trips_cnt
		FROM silver.td_green_taxi gt
			INNER JOIN silver.td_taxi_zones tz_pu
				ON tz_pu.location_id = gt.pu_location_id
			INNER JOIN silver.td_taxi_zones tz_do
				ON tz_do.location_id = gt.do_location_id
			OUTER APPLY silver.time_interval(gt.pu_datetime) ti_pu
			OUTER APPLY silver.time_interval(gt.do_datetime) ti_do
			WHERE
				gt.reject_id = 0
			GROUP BY
				gt.pu_date_key,		
				ti_pu.time_interval	,
				gt.do_date_key,
				ti_do.time_interval,
				tz_pu.borough_id,
				tz_do.borough_id,
				CASE
					WHEN gt.trip_distance <= 2 THEN 1
					WHEN gt.trip_distance <= 5 THEN 2
					WHEN gt.trip_distance <= 8 THEN 3
					WHEN gt.trip_distance <= 12 THEN 4
					WHEN gt.trip_distance <= 20 THEN 5
					WHEN gt.trip_distance > 20 THEN 6								
				END,
				IIF(gt.tip_amount > 0, 1, 0);

		SELECT @rows_count_aft = COUNT(*) FROM gold.fact_trips;
		SET @rows_loaded = @rows_count_aft - @rows_count_bef;

		SET @end_time =  SYSDATETIME();

		PRINT('Loaded records: ' + CAST((CAST(@rows_loaded AS INT)) AS VARCHAR));

		INSERT INTO etl.log_batch (
			batch_start_time, 
			batch_end_time, 
			source, 
			destination_table, 
			executed_by, 
			rows_loaded, 
			valid_rows, 
			non_valid_rows, 
			non_valid_percent, 
			duration_seconds, 
			status)
		VALUES(
			@start_time,
			@end_time,
			@current_source,
			'gold.fact_trips',
			ORIGINAL_LOGIN(),
			@rows_loaded,
			@rows_loaded,
			0,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);

		------------------------------------------------------
		-- 4. Insert - for-hire
		------------------------------------------------------

		SET @current_source = 'silver.td_for_hire';

		PRINT('');
		PRINT('>> STEP 4/4: Transform and load for-hire data into gold.fact_trips');

		SET @start_time = SYSDATETIME();
		SELECT @rows_count_bef = COUNT(*) FROM gold.fact_trips;

		INSERT INTO gold.fact_trips(
			taxi_type_id,		
			pu_date_key,			
			pu_hour,				
			do_date_key,			
			do_hour,				
			trip_time,			
			pu_borough_id,		
			do_borough_id,		
			trip_distance,		
			distance_bucket_id,	
			fare_amount,			
			tip_amount,			
			is_tip,				
			tolls_amount,		
			improvement_surcharge,	
			congestion_surcharge,
			airport_fee,			
			mta_tax,				
			extra,				
			ehail_fee,			
			bcf_fee,				
			sales_tax,			
			total_amount,		
			trips_cnt)
		SELECT
			CASE
				WHEN l.app_company = 'Uber' THEN 3
				WHEN l.app_company = 'Lyft' THEN 4
			END																			AS taxi_type_id,
			fh.pu_date_key																AS pu_date_key,
			ti_pu.time_interval															AS pu_hour,
			fh.do_date_key																AS do_date_key,
			ti_do.time_interval															AS do_hour,
			SUM(DATEDIFF(SECOND, pu_datetime, do_datetime))								AS trip_time,
			tz_pu.borough_id															AS pu_borough_id,
			tz_do.borough_id															AS do_borough_id,
			SUM(fh.trip_distance)														AS trip_distance,
			CASE
				WHEN fh.trip_distance <= 2 THEN 1
				WHEN fh.trip_distance <= 5 THEN 2
				WHEN fh.trip_distance <= 8 THEN 3
				WHEN fh.trip_distance <= 12 THEN 4
				WHEN fh.trip_distance <= 20 THEN 5
				WHEN fh.trip_distance > 20 THEN 6								
			END																			AS distance_bucket_id,
			SUM(fh.base_passenger_fee)													AS fare_amount,
			SUM(fh.tip_amount)															AS tip_amount,
			IIF(fh.tip_amount > 0, 1, 0)												AS is_tip,
			SUM(fh.tolls_amount)														AS tolls_amount,
			0																			AS improvement_surcharge,
			SUM(fh.congestion_surcharge)												AS congestion_surcharge,
			SUM(fh.airport_fee)															AS airport_fee,
			0																			AS mta_tax,
			0																			AS extra,
			0																			AS ehail_fee,
			SUM(fh.bcf_fee)																AS bcf_fee,
			SUM(fh.sales_tax)															AS sales_tax,
			SUM(fh.total_amount)														AS total_amount,
			COUNT(fh.trip_id)															AS trips_cnt
		FROM silver.td_for_hire fh
			LEFT JOIN silver.td_license l
				ON l.hvfhs_license_num = fh.hvfhs_license_num
			INNER JOIN silver.td_taxi_zones tz_pu
				ON tz_pu.location_id = fh.pu_location_id
			INNER JOIN silver.td_taxi_zones tz_do
				ON tz_do.location_id = fh.do_location_id
			OUTER APPLY silver.time_interval(fh.pu_datetime) ti_pu
			OUTER APPLY silver.time_interval(fh.do_datetime) ti_do
			WHERE 
				fh.reject_id = 0
			GROUP BY			
				CASE
					WHEN l.app_company = 'Uber' THEN 3
					WHEN l.app_company = 'Lyft' THEN 4
				END,											
				fh.pu_date_key,										
				ti_pu.time_interval,								
				fh.do_date_key,										
				ti_do.time_interval,	
				tz_pu.borough_id,									
				tz_do.borough_id,
				CASE
					WHEN fh.trip_distance <= 2 THEN 1
					WHEN fh.trip_distance <= 5 THEN 2
					WHEN fh.trip_distance <= 8 THEN 3
					WHEN fh.trip_distance <= 12 THEN 4
					WHEN fh.trip_distance <= 20 THEN 5
					WHEN fh.trip_distance > 20 THEN 6								
				END,
				IIF(fh.tip_amount > 0, 1, 0);

		SELECT @rows_count_aft = COUNT(*) FROM gold.fact_trips;
		SET @rows_loaded = @rows_count_aft - @rows_count_bef;

		SET @end_time =  SYSDATETIME();

		PRINT('Loaded records: ' + CAST((CAST(@rows_loaded AS INT)) AS VARCHAR));
		PRINT('');

		INSERT INTO etl.log_batch (
			batch_start_time, 
			batch_end_time, 
			source, 
			destination_table, 
			executed_by, 
			rows_loaded, 
			valid_rows, 
			non_valid_rows, 
			non_valid_percent, 
			duration_seconds, 
			status)
		VALUES(
			@start_time,
			@end_time,
			@current_source,
			'gold.fact_trips',
			ORIGINAL_LOGIN(),
			@rows_loaded,
			@rows_loaded,
			0,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);
		
		------------------------------------------------------
		-- 5. End stats & messages
		------------------------------------------------------

		SET @end_time_total =  SYSDATETIME();
		SELECT @rows_loaded = COUNT(*) FROM gold.fact_trips;;

		PRINT('Loading gold.fact_trips completed!');
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time_total, @end_time_total) AS VARCHAR) + 's');
		PRINT('Loaded record: ' + CAST(@rows_loaded AS VARCHAR));
		PRINT('');

		SET NOCOUNT OFF;

		COMMIT;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK;

		SET @end_time =  SYSDATETIME();

		INSERT INTO etl.log_batch (
			batch_start_time, 
			batch_end_time, 
			source, 
			destination_table, 
			executed_by, 
			rows_loaded, 
			valid_rows, 
			non_valid_rows, 
			non_valid_percent, 
			duration_seconds, 
			status,
			error_message)
		VALUES(
			@start_time,
			@end_time,
			@current_source,
			'gold.fact_trips',
			ORIGINAL_LOGIN(),
			0,
			0,
			0,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'fail',
			ERROR_MESSAGE()
		);

		PRINT('ERROR HAS OCCURED');
		PRINT('');
		PRINT('Error message: ' + ERROR_MESSAGE());
		PRINT('Error number: ' + CAST(ERROR_NUMBER() AS VARCHAR));
		PRINT('Error line: ' + CAST(ERROR_LINE() AS VARCHAR));
		PRINT('');

		SET NOCOUNT OFF;

		THROW;

	END CATCH
END

	