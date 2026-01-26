/*
=============================================================
Stored Procedure: deleting indexes 
=============================================================
Script purpose:
	This script creates stored procedure which delete CCI, PK or FK indexes

Procedure takes two arguments
1. schema name (silver, gold)
2. type of indexes (CCI, PK or F),

In order to use this procedure run (example):
EXEC etl.delete_indexes silver, F
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.delete_indexes
	@schema		NVARCHAR(128),
	@type		VARCHAR(3)
AS
BEGIN

	BEGIN TRY

		BEGIN TRAN

		DECLARE @sql NVARCHAR(MAX);

		PRINT('>> STEP 1/1: Deleting ' + @type + ' indexes');

		IF @type = 'CCI'
			BEGIN
				SELECT
					@sql = STRING_AGG(CAST(
							'IF EXISTS(
								SELECT 1 FROM sys.indexes i
									WHERE 
										i.name = ''' + ig.index_name + '''
							)
								DROP INDEX ' + ig.index_name + ' ON ' + @schema + '.' + ig.index_table + ';' 
								AS NVARCHAR(MAX)),
							CHAR(13) + CHAR(13)
							)
					FROM etl.indexes ig
						WHERE 
							ig.index_schema = @schema
							AND ig.index_type = @type;

					EXEC sp_executesql @sql
			END
		ELSE
			BEGIN
				SELECT
					@sql = STRING_AGG(CAST(
							'IF EXISTS(
								SELECT 1 FROM sys.objects s1
									LEFT JOIN sys.objects s2
										ON s1.parent_object_id = s2.object_id 
									WHERE 
										s1.type = ''' + @type + ''' ' +
										' AND s2.name = ''' + ig.index_table + '''' +
										' AND s1.name = ''' + ig.index_name + '''' +
							')
								ALTER TABLE ' + @schema + '.' + ig.index_table + 
								' DROP CONSTRAINT ' + ig.index_name + ';' 
								AS NVARCHAR(MAX)),
							CHAR(13) + CHAR(13)
							)
					FROM etl.indexes ig
						WHERE 
							ig.index_schema = @schema;

					EXEC sp_executesql @sql
				END

			PRINT(@type + ' indexes have been deleted');
			PRINT('')

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

		THROW;

	END CATCH
END