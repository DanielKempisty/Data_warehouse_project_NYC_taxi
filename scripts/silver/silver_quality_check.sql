/*
=============================================================
Stored Procedure: quality check for tables from silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. Check quality of data in table  based on conditions in table silver.qc_conditions
	2. Insert log to the table etl.log_quality_errors in case of breaking one of conditions

Procedure takes one argument - name of the table.

In order to use this procedure run (example):
EXEC etl.quality_check @table = 'td_yellow_taxi'

WARNING:
	This stored procedure works only for four main tables:
	- silver.td_yellow_taxi
	- silver.td.green_taxi
	- silver.td_for_hire
	- silver.ed.events
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.quality_check
	@table NVARCHAR(128) 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE 
		@sql			NVARCHAR(MAX),
		@rows_before	BIGINT,
		@rows_after		BIGINT;

	BEGIN TRY
		
		BEGIN TRAN;

		PRINT('>> STEP 1/1: Quality check of table: ' + @table);

		SELECT @rows_before = COUNT(*) FROM etl.log_quality_errors;

		SELECT
			@sql = STRING_AGG(CAST(
				'IF EXISTS (
					SELECT 1
					FROM silver.' + QUOTENAME(@table) + '
					WHERE ' + qc.condition + 
						' AND reject_id = 0)
				BEGIN
					PRINT(''WARNING: ' 
						+ REPLACE(qc.error_message, '''', '''''') 
						+ ', TABLE NAME: silver.' + QUOTENAME(@table) + ''');
            
					INSERT INTO etl.log_quality_errors 
						(table_name, error_id)
					VALUES
						(''' + @table + ''', ' + CAST(qc.error_id AS NVARCHAR(20)) + ');
				END;' AS NVARCHAR(MAX)),
				CHAR(13) + CHAR(13)
			)
		FROM silver.qc_conditions qc
			WHERE qc.table_name = @table;

		EXEC sp_executesql @sql;

		SELECT @rows_after = COUNT(*) FROM etl.log_quality_errors;

		IF @rows_before = @rows_after
			BEGIN
				PRINT('No quality errors');
				PRINT('');
			END
		ELSE
			PRINT('WARNING: QUALITY ERRORS: ' + CAST((@rows_after - @rows_before) AS VARCHAR));

		SET NOCOUNT OFF;

		COMMIT;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK;

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