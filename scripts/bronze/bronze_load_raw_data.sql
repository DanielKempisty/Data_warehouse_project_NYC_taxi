/*
=============================================================
Stored Procedure: Load data to the bronze layer
=============================================================
Script purpose:
	This script creates stored procedure which load data from external csv files to table from bronze layer based on data in etl.data_source

Data is loaded by using BULK INSERT method.
Procedure doesn't take any argument.

In order to use this procedure run:
EXEC bronze.load_raw_data
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE bronze.load_raw_data AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE load_cursor CURSOR
	FOR 
	SELECT path, destination_table, delimeter
	FROM etl.data_source;

	DECLARE
		@path				NVARCHAR(4000),
		@destination_table	NVARCHAR(128),
		@delimeter			CHAR(1),
		@start_time_total	DATETIME2(0),
		@end_time_total		DATETIME2(0);
		
	SET @start_time_total = SYSDATETIME();

	OPEN load_cursor;

	FETCH NEXT FROM load_cursor INTO @path, @destination_table, @delimeter;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY

			BEGIN TRAN

			DECLARE 
				@sql NVARCHAR(MAX),
				@start_time DATETIME2(0),
				@end_time DATETIME2(0),
				@rows_count_bef BIGINT,
				@rows_count_aft BIGINT;

				SET @start_time = SYSDATETIME();

				PRINT('>> Loading data into ' +  @destination_table);
				
				SET @sql = N'SELECT @cnt = COUNT(*) FROM ' + @destination_table;
				EXEC sp_executesql @sql, N'@cnt BIGINT OUTPUT', @cnt = @rows_count_bef OUTPUT;

				SET @sql =
					'BULK INSERT ' + @destination_table +
						' FROM ''' + @path + '''
						WITH (
							FIRSTROW = 2,
							FIELDTERMINATOR = ''' + @delimeter + ''',  
							TABLOCK
						);'

				EXEC sp_executesql @sql;

				SET @sql = N'SELECT @cnt = COUNT(*) FROM ' + @destination_table;
				EXEC sp_executesql @sql, N'@cnt BIGINT OUTPUT', @cnt = @rows_count_aft OUTPUT;

				SET @rows_count_aft = @rows_count_aft - @rows_count_bef;

				SET @end_time = SYSDATETIME();

				PRINT('Loaded records: ' + CAST(@rows_count_aft AS VARCHAR) + ', Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 's');
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
					@path, 
					@destination_table,
					ORIGINAL_LOGIN(),
					@rows_count_aft,
					@rows_count_aft,
					0,
					0,
					DATEDIFF(SECOND, @start_time, @end_time),
					'success'
				);

				COMMIT;

			END TRY
			BEGIN CATCH

				IF @@TRANCOUNT > 0
					ROLLBACK;

				SET @end_time = SYSDATETIME();

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
					@path, 
					@destination_table,
					ORIGINAL_LOGIN(),
					0,
					0,
					0,
					0,
					DATEDIFF(SECOND, @start_time, @end_time),
					'fail'
				);

				PRINT('');
				PRINT('ERROR HAS OCCURED');
				PRINT('');
				PRINT('Error message: ' + ERROR_MESSAGE());
				PRINT('Error number: ' + CAST(ERROR_NUMBER() AS VARCHAR));
				PRINT('Error line: ' + CAST(ERROR_LINE() AS VARCHAR));

				SET NOCOUNT OFF;

				THROW;

			END CATCH

			FETCH NEXT FROM load_cursor INTO @path, @destination_table, @delimeter;
		
	END

	CLOSE load_cursor;
	DEALLOCATE load_cursor;

	SET @end_time_total	 = SYSDATETIME();

	PRINT('Loading completed')
	PRINT('Total loading time: ' + CAST(DATEDIFF(SECOND, @start_time_total, @end_time_total) AS VARCHAR) + 's');
	PRINT('');

	SET @end_time_total = SYSDATETIME();

	SET NOCOUNT OFF;
END