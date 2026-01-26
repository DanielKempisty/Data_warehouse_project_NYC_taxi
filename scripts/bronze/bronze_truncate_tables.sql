/*
=============================================================
Stored Procedure: Truncate data from the bronze layer
=============================================================
Script purpose:
	This script creates stored procedure which truncate tables from bronze layer.

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC bronze.truncate_table

WARNING:
	Running this procedure will truncate all tables in bronze layer 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE bronze.truncate_table AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE truncate_cursor CURSOR
	FOR 
	SELECT ds.destination_table
	FROM (SELECT DISTINCT destination_table FROM etl.data_source) ds;

	DECLARE
		@destination_table	NVARCHAR(128);

	OPEN truncate_cursor;

	FETCH NEXT FROM truncate_cursor INTO @destination_table

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY

			BEGIN TRAN

				PRINT('>> Truncating table ' +  @destination_table);

				EXEC('TRUNCATE TABLE ' + @destination_table);

				PRINT('Table ' +  @destination_table + ' has been truncated');
				PRINT('');

				COMMIT;

				SET NOCOUNT OFF;

			END TRY
			BEGIN CATCH

				IF @@TRANCOUNT > 0
					ROLLBACK;
				
				PRINT('');
				PRINT('ERROR HAS OCCURED');
				PRINT('');
				PRINT('Error message: ' + ERROR_MESSAGE());
				PRINT('Error number: ' + CAST(ERROR_NUMBER() AS VARCHAR));
				PRINT('Error line: ' + CAST(ERROR_LINE() AS VARCHAR));

				SET NOCOUNT OFF;

				THROW;

			END CATCH

			FETCH NEXT FROM truncate_cursor INTO @destination_table;
		
	END

	CLOSE truncate_cursor;
	DEALLOCATE truncate_cursor;

END