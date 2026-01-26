/*
=============================================================
Stored Procedure: Load date and holiday data to the silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate table silver.hd_date from silver layer
	2. tranform and clean data from bronze layer with holiday data
	3. load holiday data from bronze to table from silver layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_holiday_data_to_silver

WARNING:
	Running this procedure will truncate silver.hd_date table in silver layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_holiday_data_to_silver AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE @start_time DATETIME2(0), @end_time DATETIME2(0), @rows_count BIGINT; 

	BEGIN TRY

		BEGIN TRAN;

		SET @start_time = SYSDATETIME();

		------------------------------------------------------
		-- 1. Truncate existing table
		------------------------------------------------------

		PRINT('>> STEP 1/2: Truncating table silver.hd_date');

		TRUNCATE TABLE silver.hd_date;

		PRINT('silver.hd_date table has been truncated');

		------------------------------------------------------
		-- 2. Clean & transform data
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load data into silver.hd_date table');

		WITH calendar AS (
			SELECT CAST('2024-01-01' AS DATE) AS lu_date

			UNION ALL

			SELECT DATEADD(DAY, 1, lu_date)
			FROM calendar
			WHERE lu_date < '2024-12-31'
		)

		------------------------------------------------------
		-- 3. Insert to silver.hd_date table
		------------------------------------------------------

		INSERT INTO silver.hd_date(
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
			CAST(REPLACE(c.lu_date, '-', '') AS BIGINT)			AS date_key,
			c.lu_date											AS lu_date,
			DATEPART(QQ, lu_date)								AS lu_quarter,
			MONTH(lu_date)										AS lu_month,
			DAY(lu_date)										AS lu_day,
			IIF(DATEPART(WEEKDAY, c.lu_date) IN (7, 1), 1, 0)	AS is_weekend,
			IIF(h.holiday_date IS NOT NULL, 1, 0)				AS is_holiday,
			h.holiday_name										AS holiday_name
		FROM calendar c
			LEFT JOIN bronze.hd_holidays h
				ON c.lu_date = h.holiday_date
		OPTION (MAXRECURSION 0);

		INSERT INTO silver.hd_date( -- -1 date_key for dates from diffrent year than 2024
			date_key,
			full_date,
			quarter,
			month,
			day,
			is_weekend,
			is_holiday,
			holiday_name)
		VALUES(
			-1,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL)

		------------------------------------------------------
		-- 4. End stats & messages
		------------------------------------------------------
		SELECT @rows_count = COUNT(*) FROM silver.hd_date;

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
			'bronze.hd_holidays',
			'silver.hd_date',
			ORIGINAL_LOGIN(),
			@rows_count,
			@rows_count,
			@rows_count,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);

		PRINT('Loading silver.hd_date completed!');
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
			'bronze.hd_holidays',
			'silver.hd_date',
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


 



