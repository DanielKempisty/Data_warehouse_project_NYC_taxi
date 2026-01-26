/*
=============================================================
Stored Procedure: Load events data to the silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate table silver.ed_events from silver layer
	2. tranform and clean data from bronze layer with events data
	3. load events data from bronze to table from silver layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_events_data_to_silver

WARNING:
	Running this procedure will truncate silver.ed_events table in silver layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_events_data_to_silver AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE @start_time DATETIME2(0), @end_time DATETIME2(0), @rows_count BIGINT; 

	BEGIN TRY

		BEGIN TRAN;

		SET @start_time = SYSDATETIME();

		------------------------------------------------------
		-- 1. Truncate existing table
		------------------------------------------------------
		PRINT('>> STEP 1/2: Truncating table silver.ed_events');

		TRUNCATE TABLE silver.ed_events;

		PRINT('silver.ed_events table has been truncated');

		------------------------------------------------------
		-- 2. Clean & transform data
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load data into silver.ed_events table');

		WITH transf_events AS(
			SELECT DISTINCT 
				REPLACE(TRIM(event_id), '"', '')							AS event_id,
				REPLACE(TRIM(event_name), '"', '')							AS event_name,
				REPLACE(TRIM(start_datetime), '"', '')						AS start_datetime,
				REPLACE(TRIM(end_datetime), '"', '')						AS end_datetime,
				REPLACE(TRIM(event_agency), '"', '')						AS event_agency,
				REPLACE(TRIM(event_type), '"', '')							AS event_type,
				REPLACE(TRIM(event_bourough), '"', '')						AS event_bourough,
				IIF(REPLACE(TRIM(street_closure_type), '"', '')	= '',
					'none',
					REPLACE(TRIM(street_closure_type), '"', ''))			AS street_closure_type
			FROM bronze.ed_events)

		------------------------------------------------------
		-- 3. Insert to silver.ed_events table
		------------------------------------------------------

		INSERT INTO silver.ed_events(
			event_id,				
			event_name,			
			start_datetime,	
			start_date_key,
			end_datetime,	
			end_date_key,
			agency_id,				
			event_type_id,			
			borough_id,			
			street_closure_type_id,
			reject_id
			)

		SELECT
			IIF(te.event_id = '', NULL, event_id)												AS event_id,
			IIF(te.event_name = '', NULL, event_name)											AS event_name,
			TRY_CONVERT(DATETIME2(0), te.start_datetime)										AS start_datetime,
			dk_s.date_key																		AS start_date_key,
			TRY_CONVERT(DATETIME2(0), te.end_datetime)											AS end_datetime,
			dk_e.date_key																		AS end_date_key,
			ea.agency_id																		AS agency_id,
			et.event_type_id																	AS event_type_id,
			b.borough_id																		AS borough_id,
			sct.street_closure_type_id															AS street_closure_type_id,
			vr.reject_id																		AS reject_id
		FROM transf_events te
			LEFT JOIN silver.ed_event_agency ea
				ON ea.agency_name = te.event_agency
			LEFT JOIN silver.ed_event_type et
				ON et.event_type = te.event_type
			LEFT JOIN silver.ed_street_closure_type sct
				ON sct.street_closure_type = te.street_closure_type
			LEFT JOIN silver.borough b
				ON b.borough_name = te.event_bourough
			OUTER APPLY silver.validate_events_records(
							TRY_CONVERT(DATETIME2(0), te.start_datetime),
							TRY_CONVERT(DATETIME2(0), te.end_datetime)
						) vr
			OUTER APPLY silver.create_date_key(TRY_CONVERT(DATE, te.start_datetime)) dk_s
			OUTER APPLY silver.create_date_key(TRY_CONVERT(DATE, te.end_datetime)) dk_e
						
		
		------------------------------------------------------
		-- 4. End stats & messages
		------------------------------------------------------
		SELECT @rows_count = COUNT(*) FROM silver.ed_events;

		SET @end_time =  SYSDATETIME()

		PRINT('Loaded records: ' + CAST(@rows_count AS VARCHAR));
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
			'bronze.ed_events',
			'silver.ed_events',
			ORIGINAL_LOGIN(),
			@rows_count,
			@rows_count,
			@rows_count,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);

		PRINT('Loading silver.ed_events completed!');
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 's');
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
			'bronze.ed_events',
			'silver.ed_events',
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


 

