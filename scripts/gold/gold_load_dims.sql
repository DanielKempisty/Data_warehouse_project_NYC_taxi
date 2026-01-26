/*
=============================================================
Stored Procedure: Load DIM tables to the gold layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate DIM tables from gold layer
	2. tranform and aggregate data from silver layer
	3. load DIM tables top gold layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_dim_tables_to_gold

WARNING:
	Running this procedure will truncate all DIM tables in gold layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_dim_tables_to_gold AS
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
		-- 1. Dim borough
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'silver.borough';
		SET @current_destination= 'gold.dim_borough';

		PRINT('>> STEP 1/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_borough;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 2/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_borough(
			borough_id,
			borough_name,
			is_airport
		)
		SELECT
			borough_id,
			borough_name,
			IIF(is_airport = 1, 'Yes', 'No')	AS is_airport
		FROM silver.borough;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_borough;

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
		-- 2. Dim agency
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'silver.ed_event_type';
		SET @current_destination= 'gold.dim_event_type';

		PRINT('>> STEP 3/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_event_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 4/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_event_type(
			event_type_id,
			event_type
		)
		SELECT
			event_type_id,
			event_type
		FROM silver.ed_event_type;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_event_type;

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
		-- 3. Dim event type
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'silver.ed_event_agency';
		SET @current_destination= 'gold.dim_event_agency';

		PRINT('>> STEP 5/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_event_agency;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 6/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_event_agency(
			agency_id,
			agency
		)
		SELECT
			agency_id,
			agency_name
		FROM silver.ed_event_agency;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_event_agency;

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
		-- 4. Dim street closure type
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'silver.ed_street_closure_type';
		SET @current_destination= 'gold.dim_street_closure_type';

		PRINT('>> STEP 7/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_street_closure_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 8/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_street_closure_type(
			street_closure_type_id,
			street_closure_type
		)
		SELECT
			street_closure_type_id,
			street_closure_type
		FROM silver.ed_street_closure_type;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_street_closure_type;

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
		-- 5. Dim date
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'silver.hd_date';
		SET @current_destination= 'gold.dim_date';

		PRINT('>> STEP 9/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_date;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 10/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_date(
			date_key,
			full_date,
			quarter,
			month,
			day,
			is_weekend,
			is_holiday,
			holiday_name
		)
		SELECT
			date_key,
			full_date,
			quarter,
			month,
			day,
			IIF(is_weekend = 1, 'Yes', 'No')		AS is_weekend,
			IIF(is_holiday = 1, 'Yes', 'No')		AS is_holiday,
			holiday_name
		FROM silver.hd_date
			WHERE date_key != -1;

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_date;

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
		-- 6. Dim taxi type
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'gold.dim_taxi_type';

		PRINT('>> STEP 11/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_taxi_type;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 12/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_taxi_type(
			taxi_type_id,
			taxi_type
		)
		VALUES
			(1, 'Yellow'),
			(2, 'Green'),
			(3, 'Uber'),
			(4, 'Lyft');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_taxi_type;

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
		-- 7. Dim trip distance bucket
		------------------------------------------------------

		SET @start_time = SYSDATETIME();
		SET @current_source = 'manual';
		SET @current_destination= 'gold.dim_trip_distance_bucket';

		PRINT('>> STEP 13/14: Truncating table ' + @current_destination);

		TRUNCATE TABLE gold.dim_trip_distance_bucket;

		PRINT(@current_destination + ' table has been truncated');

		PRINT('');
		PRINT('>> STEP 14/14: Transform and load data into ' + @current_destination + ' table');

		INSERT INTO gold.dim_trip_distance_bucket(
			distance_bucket_id,
			distance_bucket			
		)
		VALUES
			(1, '0-2'),
			(2, '2-5'),
			(3, '5-8'),
			(4, '8-12'),
			(5, '12-20'),
			(6, '20+');

		SET @end_time = SYSDATETIME();

		SELECT @rows_count = COUNT(*) FROM gold.dim_trip_distance_bucket;

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
		-- 8. End stats & messages
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