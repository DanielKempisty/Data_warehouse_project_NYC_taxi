/*
=============================================================
Stored Procedure: Load green taxi data to the silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate tables from silver layer with green taxi data
	2. tranform and clean data from bronze layer with green taxi data
	3. load green taxi data from bronze to table from silver layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_green_taxi_data_to_silver

WARNING:
	Running this procedure will truncate all green taxi tables in silver layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_green_taxi_data_to_silver AS
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

		PRINT('>> STEP 1/2: Truncating table silver.td_green_taxi');

		TRUNCATE TABLE silver.td_green_taxi;

		PRINT('silver.td_green_taxi table has been truncated');

		------------------------------------------------------
		-- 2. Clean & transform data
		--		2.1 transf_green_1 --> cleanup & tranformation
		--		2.2 transf_green_2 --> handle total_amount column issue
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load data into silver.td_green_taxi table');

		WITH transf_green_1 AS (
			SELECT 
				ca.vendor_id,
				gt.pu_datetime,
				dk_pu.date_key				AS pu_date_key,
				gt.do_datetime,		
				dk_do.date_key				AS do_date_key,
				gt.pu_location_id,
				gt.do_location_id,
				ca.passenger_cnt,
				ca.trip_distance,
				ca.trip_type_id,
				ca.store_and_fwd,
				ca.tariff_type_id,
				ca.payment_type_id,
				ca.fare_amount,
				ca.tolls_amount,
				ca.improvement_surcharge,
				ca.congestion_surcharge,
				ca.ehail_fee,
				ca.mta_tax,
				ca.extra,
				ca.tip_amount,
				ca.total_amount
			FROM bronze.td_green_taxi gt
				LEFT JOIN silver.td_taxi_zones tzpu
					ON tzpu.location_id = gt.pu_location_id
				LEFT JOIN silver.td_taxi_zones tzdo
					ON tzdo.location_id = gt.do_location_id
			OUTER APPLY (
					SELECT
						IIF(gt.vendor_id NOT IN (1, 2), -1, gt.vendor_id)							AS vendor_id,
						IIF(gt.passenger_cnt = 0, 1, COALESCE(ABS(gt.passenger_cnt), 1))			AS passenger_cnt, -- treat NULL and zero values as 1
						COALESCE(gt.trip_distance, 0) * 1.609344									AS trip_distance, -- converting miles to kilometers
						IIF(gt.trip_type IS NULL, 1, gt.trip_type)									AS trip_type_id,
						IIF(gt.store_and_fwd = 'Y', 1, 0)											AS store_and_fwd,
						CASE 
							WHEN gt.tariff_type IS NULL THEN 
								(CASE
									WHEN gt.pu_location_id = 1 OR gt.do_location_id = 1 THEN 3						-- Newark Airport tariff = 3
									WHEN gt.pu_location_id IN (132, 138) OR gt.do_location_id IN (132, 138) THEN 2	-- JFK and LaGuardia airports tariff = 2 
									ELSE 1
								END)
							WHEN gt.tariff_type = 99 THEN 1
							ELSE gt.tariff_type
						END																			AS tariff_type_id,
						IIF(gt.payment_type = 0, 1, COALESCE(gt.payment_type, 1))					AS payment_type_id, -- treat NULL and 0 values as 1
						COALESCE(ABS(gt.fare_amount), 0)											AS fare_amount,
						COALESCE(ABS(gt.tolls_amount), 0)											AS tolls_amount,
						COALESCE(ABS(gt.improvement_surcharge), 0)									AS improvement_surcharge,
						CASE 
							WHEN gt.congestion_surcharge IS NULL THEN	-- filling NULL values based on location
								(CASE
									WHEN tzpu.is_cbd = 1 OR tzdo.is_cbd = 1 THEN 2.5
									ELSE 0.0
								END)
							ELSE COALESCE(ABS(gt.congestion_surcharge), 0)
						END																			AS congestion_surcharge,
						COALESCE(ABS(gt.ehail_fee), 0)												AS ehail_fee,
						COALESCE(ABS(gt.mta_tax), 0)												AS mta_tax,
						COALESCE(ABS(gt.extra), 0)													AS extra,
						COALESCE(ABS(gt.tip_amount), 0)												AS tip_amount,
						COALESCE(ABS(gt.total_amount), 0)											AS total_amount
					) ca 
			OUTER APPLY silver.create_date_key(gt.pu_datetime) dk_pu
			OUTER APPLY silver.create_date_key(gt.do_datetime) dk_do
			),

		transf_green_2 AS (
			SELECT
				ty1.vendor_id,
				ty1.pu_datetime,
				ty1.pu_date_key,
				ty1.do_datetime,
				ty1.do_date_key,
				ty1.pu_location_id,
				ty1.do_location_id,
				ty1.passenger_cnt,
				ty1.trip_distance,
				ty1.trip_type_id,
				ty1.store_and_fwd,
				ty1.tariff_type_id,
				ty1.payment_type_id,
				ty1.fare_amount,
				ty1.tolls_amount,
				ty1.improvement_surcharge,
				ty1.congestion_surcharge,
				ty1.ehail_fee,
				ty1.mta_tax,
				ty1.extra,
				ty1.tip_amount,
				IIF(ty1.total_amount - (ty1.fare_amount + ty1.tolls_amount + ty1.improvement_surcharge + ty1.congestion_surcharge + 
										ty1.ehail_fee + ty1.mta_tax + ty1.extra + ty1.tip_amount) 
										<> 0
					AND (ty1.total_amount - (ty1.fare_amount + ty1.tolls_amount + ty1.improvement_surcharge + ty1.congestion_surcharge + 
										ty1.ehail_fee + ty1.mta_tax + ty1.extra + ty1.tip_amount) 
										= -1.0 * (ty1.congestion_surcharge + ty1.improvement_surcharge)),
					ty1.total_amount + ty1.congestion_surcharge + ty1.improvement_surcharge, 
					ty1.total_amount) AS total_amount 
			FROM transf_green_1 ty1
		)

		------------------------------------------------------
		-- 3. Insert to silver.td_green_taxi table
		------------------------------------------------------
		INSERT INTO silver.td_green_taxi (
			trip_id,
			vendor_id,
			pu_datetime,
			pu_date_key,
			do_datetime,
			do_date_key,
			pu_location_id,
			do_location_id,
			passenger_cnt,
			trip_distance,
			trip_type_id,
			store_and_fwd,
			tariff_type_id,
			payment_type_id,
			fare_amount,
			tolls_amount,
			improvement_surcharge,
			congestion_surcharge,
			ehail_fee,
			mta_tax,
			extra,
			tip_amount,
			total_amount,
			reject_id)
		SELECT
			NEXT VALUE FOR silver.trip_id_seq AS trip_id,
			ty2.vendor_id,
			ty2.pu_datetime,
			ty2.pu_date_key,
			ty2.do_datetime,
			ty2.do_date_key,
			ty2.pu_location_id,
			ty2.do_location_id,
			ty2.passenger_cnt,
			ty2.trip_distance,
			ty2.trip_type_id,
			ty2.store_and_fwd,
			ty2.tariff_type_id,
			ty2.payment_type_id,
			ty2.fare_amount,
			ty2.tolls_amount,
			ty2.improvement_surcharge,
			ty2.congestion_surcharge,
			ty2.ehail_fee,
			ty2.mta_tax,
			ty2.extra,
			ty2.tip_amount,
			ty2.total_amount,
			vr.reject_id
		FROM transf_green_2 ty2
		OUTER APPLY silver.validate_yellow_green_records(
							ty2.trip_distance,
							ty2.total_amount,
							ty2.pu_datetime,
							ty2.do_datetime,
							ty2.total_amount - (ty2.fare_amount + ty2.tolls_amount + ty2.improvement_surcharge +										 ty2.congestion_surcharge + ty2.ehail_fee + ty2.mta_tax + ty2.tip_amount + ty2.extra),
							ty2.vendor_id
						) vr
		
		------------------------------------------------------
		-- 4. End stats & messages
		------------------------------------------------------
		SELECT @valid_data = COUNT(*) FROM silver.td_green_taxi WHERE reject_id = 0;
		SELECT @non_valid_data = COUNT(*) FROM silver.td_green_taxi WHERE reject_id <> 0;
		SET @reject_percent = 
			CASE 
				WHEN (@non_valid_data + @valid_data) = 0 THEN 0
				ELSE (@non_valid_data * 100.0) / (@non_valid_data + @valid_data)
			END;

		SET @end_time =  SYSDATETIME()

		PRINT('Loaded records: ' + CAST((CAST(@valid_data + @non_valid_data AS INT)) AS VARCHAR));

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
			'bronze.td_green_taxi',
			'silver.td_green_taxi',
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

		PRINT('');
		PRINT('Loading silver.td_green_taxi completed!');
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

		SET @end_time =  SYSDATETIME()

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
			'bronze.td_green_taxi',
			'silver.td_green_taxi',
			ORIGINAL_LOGIN(),
			0,
			0,
			0,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'failed',
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

	