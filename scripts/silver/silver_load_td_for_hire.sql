/*
=============================================================
Stored Procedure: Load for-hire data to the silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate tables from silver layer with for-hire data
	2. tranform and clean data from bronze layer with for-hire data
	3. load for-hire data from bronze to table from silver layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_for_hire_data_to_silver

WARNING:
	Running this procedure will truncate all for-hire tables in silver layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_for_hire_data_to_silver AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE @start_time DATETIME2(0), @end_time DATETIME2(0); 
	DECLARE @valid_data DECIMAL(12,2), @non_valid_data DECIMAL(12,2), @reject_percent DECIMAL(5,2);

	BEGIN TRY

		BEGIN TRAN;

		SET @start_time = SYSDATETIME();

		------------------------------------------------------
		-- 1. Truncate existing table
		------------------------------------------------------

		PRINT('>> STEP 1/2: Truncating table silver.td_for_hire');

		TRUNCATE TABLE silver.td_for_hire;

		PRINT('silver.td_for_hire table has been truncated');

		------------------------------------------------------
		-- 2. Clean & transform data
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load data into silver.td_for_hire');

		WITH transf_fh AS (
			SELECT 
				fh.hvfhs_license_num,
				fh.dispatch_base_num,
				fh.originate_base_num,
				fh.request_datetime,
				fh.on_scene_datetime,
				fh.pu_datetime,
				dk_pu.date_key				AS pu_date_key,
				fh.do_datetime,	
				dk_do.date_key				AS do_date_key,
				fh.pu_location_id,
				fh.do_location_id,
				ca.trip_distance,
				ca.shared_request,
				ca.shared_match,
				ca.access_a_ride,
				ca.wav_request,
				ca.wav_match,
				ca.base_passenger_fee,
				ca.driver_pay,
				ca.tolls_amount,
				ca.congestion_surcharge,
				ca.airport_fee,
				ca.bcf_fee,
				ca.sales_tax,
				ca.tip_amount,
				ca.total_amount
			FROM bronze.td_for_hire fh
			OUTER APPLY (
					SELECT
						COALESCE(fh.trip_distance, 0) * 1.609344							AS trip_distance, -- converting miles to kilometers
						IIF(fh.shared_request = 'Y', 1, 0)									AS shared_request,
						IIF(fh.shared_match = 'Y', 1, 0)									AS shared_match,
						IIF(fh.access_a_ride = 'Y', 1, 0)									AS access_a_ride,
						IIF(fh.wav_request = 'Y', 1, 0)										AS wav_request,
						IIF(fh.wav_match = 'Y', 1, 0)										AS wav_match,
						COALESCE(fh.base_passenger_fee, 0)									AS base_passenger_fee,
						COALESCE(fh.driver_pay, 0)											AS driver_pay,
						COALESCE(fh.tolls_amount, 0)										AS tolls_amount,
						COALESCE(fh.congestion_surcharge, 0)								AS congestion_surcharge,
						COALESCE(fh.airport_fee, 0)											AS airport_fee,
						COALESCE(fh.bcf_fee, 0)												AS bcf_fee,
						COALESCE(fh.sales_tax, 0)											AS sales_tax,
						COALESCE(fh.tip_amount, 0)											AS tip_amount,
						COALESCE(fh.base_passenger_fee, 0) + COALESCE(fh.tolls_amount, 0) + COALESCE(fh.congestion_surcharge, 0) 
						+ COALESCE(fh.airport_fee, 0) + COALESCE(fh.bcf_fee, 0) + COALESCE(fh.sales_tax, 0) 
						+ COALESCE(fh.tip_amount, 0)										AS total_amount
					) ca
				OUTER APPLY silver.create_date_key(fh.pu_datetime) dk_pu
				OUTER APPLY silver.create_date_key(fh.do_datetime) dk_do
			)

		------------------------------------------------------
		-- 3. Insert to silver.td_for_fire table
		------------------------------------------------------
		INSERT INTO silver.td_for_hire(
			trip_id,
			hvfhs_license_num,
			dispatch_base_num,
			originate_base_num,
			request_datetime,
			on_scene_datetime,
			pu_datetime,
			pu_date_key,
			do_datetime,
			do_date_key,
			pu_location_id,
			do_location_id,
			trip_distance,
			shared_request,
			shared_match,
			access_a_ride,
			wav_request,
			wav_match,
			base_passenger_fee,
			driver_pay,
			tolls_amount,
			congestion_surcharge,
			airport_fee,
			bcf_fee,
			sales_tax,
			tip_amount,
			total_amount,
			reject_id)
		SELECT
			NEXT VALUE FOR silver.trip_id_seq AS trip_id,
			tfh.hvfhs_license_num,
			tfh.dispatch_base_num,
			tfh.originate_base_num,
			tfh.request_datetime,
			tfh.on_scene_datetime,
			tfh.pu_datetime,
			tfh.pu_date_key,
			tfh.do_datetime,
			tfh.do_date_key,
			tfh.pu_location_id,
			tfh.do_location_id,
			tfh.trip_distance,
			tfh.shared_request,
			tfh.shared_match,
			tfh.access_a_ride,
			tfh.wav_request,
			tfh.wav_match,
			tfh.base_passenger_fee,
			tfh.driver_pay,
			tfh.tolls_amount,
			tfh.congestion_surcharge,
			tfh.airport_fee,
			tfh.bcf_fee,
			tfh.sales_tax,
			tfh.tip_amount,
			tfh.total_amount,
			vr.reject_id
		FROM transf_fh tfh
		OUTER APPLY silver.validate_for_hire_records(
						tfh.trip_distance,
						tfh.total_amount,
						tfh.pu_datetime,
						tfh.do_datetime,
						tfh.base_passenger_fee,
						tfh.driver_pay,
						tfh.tolls_amount,
						tfh.congestion_surcharge,
						tfh.airport_fee,
						tfh.bcf_fee,
						tfh.sales_tax,
						tfh.tip_amount
						) vr
		
		------------------------------------------------------
		-- 4. End stats & messages
		------------------------------------------------------
		SELECT @valid_data = COUNT(*) FROM silver.td_for_hire WHERE reject_id = 0;
		SELECT @non_valid_data = COUNT(*) FROM silver.td_for_hire WHERE reject_id <> 0;
		SET @reject_percent = 
			CASE 
				WHEN (@non_valid_data + @valid_data) = 0 THEN 0
				ELSE (@non_valid_data * 100.0) / (@non_valid_data + @valid_data)
			END;

		SET @end_time =  SYSDATETIME()

		PRINT('Loaded records: ' + CAST((CAST(@valid_data + @non_valid_data AS INT)) AS VARCHAR));
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
			'bronze.td_for_hire',
			'silver.td_for_hire',
			ORIGINAL_LOGIN(),
			@valid_data + @non_valid_data,
			@valid_data,
			@non_valid_data,
			CASE 
				WHEN (@non_valid_data + @valid_data) = 0 THEN 0
				ELSE (@non_valid_data * 100.0) / (@non_valid_data + @valid_data)
			END,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);

		PRINT('Loading silver.td_for_hire completed!');
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 's');
		PRINT('Non-valid data: ' + CAST(@reject_percent AS VARCHAR) + '%');
		PRINT('');

		IF @reject_percent > 5
		BEGIN
			PRINT('WARNING: OVER 5% OF DATA WAS CLASSIFY AS NON-VALID. CHECK COLUMN reject_id');
			PRINT('');
		END

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
			'bronze.td_for_hire',
			'silver.td_for_hire',
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

	