/*
=============================================================
Stored Procedure: adding indexes
=============================================================
Script purpose:
	This script creates stored procedure which creates CCI, PK or FK indexes

Procedure takes one any argument: schema name

In order to use this procedure run:
EXEC etl.add_indexes silver
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.add_indexes
	@schema NVARCHAR(128)
AS
BEGIN
	
	BEGIN TRY

		BEGIN TRAN

		DECLARE @sql NVARCHAR(MAX);

		PRINT('>> STEP 1/3: Adding CCI indexes');

		SELECT
			@sql = STRING_AGG(CAST(
					'CREATE CLUSTERED COLUMNSTORE INDEX ' + ig.index_name +
					' ON ' + ig.index_schema + '.' + ig.index_table + ';'
					AS NVARCHAR(MAX)),
					CHAR(13) + CHAR(13)
					)
			FROM etl.indexes ig
				WHERE 
					ig.index_type = 'CCI'
					AND ig.index_schema = @schema;

		EXEC sp_executesql @sql;
		
		IF EXISTS(
			SELECT 1 FROM etl.indexes ig 
				WHERE 
					ig.index_type = 'CCI'
					AND ig.index_schema = @schema)
			PRINT('CCI indexes have been added');
		ELSE
			PRINT('No CCI indexes to add')

		PRINT('');

		PRINT('>> STEP 2/3: Adding PK indexes');

		SELECT
			@sql = STRING_AGG(CAST(
					'ALTER TABLE ' + ig.index_schema + '.' + ig.index_table +
					' ADD CONSTRAINT ' + ig.index_name + ' PRIMARY KEY(' + ig.index_column + ');'
					AS NVARCHAR(MAX)),
					CHAR(13) + CHAR(13)
					)
			FROM etl.indexes ig
				WHERE 
					ig.index_type = 'PK'
					AND ig.index_schema = @schema;

		EXEC sp_executesql @sql;

		IF EXISTS(
			SELECT 1 FROM etl.indexes ig 
				WHERE 
					ig.index_type = 'PK'
					AND ig.index_schema = @schema)
			PRINT('PK indexes have been added');
		ELSE
			PRINT('No PK indexes to add')

		PRINT('');

		PRINT('>> STEP 3/3: Adding FK indexes');

		SELECT
			@sql = STRING_AGG(CAST(		
					'ALTER TABLE ' + ig.index_schema + '.' + ig.index_table +
					' ADD CONSTRAINT ' + ig.index_name + ' FOREIGN KEY(' + ig.index_column + ') REFERENCES ' + @schema + '.' + ig.reference_table + '(' +  ig.reference_column + ');'
					AS NVARCHAR(MAX)),
					CHAR(13) + CHAR(13)
					)
			FROM etl.indexes ig
				WHERE 
					ig.index_type = 'FK'
					AND ig.index_schema = @schema;

		EXEC sp_executesql @sql

		IF EXISTS(
			SELECT 1 FROM etl.indexes ig 
				WHERE 
					ig.index_type = 'FK'
					AND ig.index_schema = @schema)
			PRINT('FK indexes have been added');
		ELSE
			PRINT('FK CCI indexes to add')

		PRINT('');

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