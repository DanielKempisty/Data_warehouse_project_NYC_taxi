/*
=============================================================
Stored Procedure: Load fact_events tabel to the gold layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate fact_events table from gold layer
	2. tranform and clean data from silver layer with events data
	3. load events data from silver to gold layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_events_to_gold

WARNING:
	Running this procedure will truncate fact_events table in gold layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_events_to_gold AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE 
		@start_time DATETIME2(0), 
		@end_time DATETIME2(0), 
		@rows_loaded BIGINT;

	BEGIN TRY

		BEGIN TRAN;

		------------------------------------------------------
		-- 1. Truncate existing table
		------------------------------------------------------

		PRINT('>> STEP 1/2: Truncating table gold.fact_events');

		TRUNCATE TABLE gold.fact_events;

		PRINT('gold.fact_events table has been truncated');

		------------------------------------------------------
		-- 2. Tranform & Insert
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load event data into gold.fact_events');

		SET @start_time = SYSDATETIME();

		INSERT INTO gold.fact_events(
			event_date_key,
			agency_id,
			event_type_id,
			borough_id,
			street_closure_type_id,
			events_cnt
		)
		SELECT
			e.start_date_key			AS start_date_key,
			e.agency_id					AS agency_id,
			e.event_type_id				AS event_type_id,
			e.borough_id				AS borough_id,
			e.street_closure_type_id	AS street_closure_type_id,
			COUNT(e.event_occurance_id) AS events_cnt
		FROM silver.ed_events e
			JOIN gold.dim_date d
				ON d.full_date 
					BETWEEN CAST(e.start_datetime AS DATE)
					AND CAST(e.end_datetime AS DATE)
			WHERE
				e.reject_id = 0
			GROUP BY
				e.start_date_key,	
				e.end_date_key,			
				e.agency_id,				
				e.event_type_id,			
				e.borough_id,			
				e.street_closure_type_id

		SELECT @rows_loaded = COUNT(*) FROM gold.fact_events;

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
			'silver.ed_events',
			'gold.fact_events',
			ORIGINAL_LOGIN(),
			@rows_loaded,
			@rows_loaded,
			0,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);
		
		------------------------------------------------------
		-- 3. End stats & messages
		------------------------------------------------------

		PRINT('Loading gold.fact_events completed!');
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 's');
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
			'silver.ed_events',
			'gold.fact_events',
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

	 