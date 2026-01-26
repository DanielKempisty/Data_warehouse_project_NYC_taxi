------------------------------------------------------
-- 1. Indexes table
------------------------------------------------------
IF OBJECT_ID('etl.indexes', 'U') IS NOT NULL
		DROP TABLE etl.indexes;

	CREATE TABLE etl.indexes (
		index_id			SMALLINT IDENTITY(1,1) NOT NULL,
		index_schema		NVARCHAR(128) NOT NULL,
		index_table			NVARCHAR(128) NOT NULL,
		index_column		NVARCHAR(128) NULL,
		index_type			CHAR(3) NOT NULL,
		index_name			NVARCHAR(128) NOT NULL,
		reference_table		NVARCHAR(128) NULL,
		reference_column	NVARCHAR(128) NULL
	);
GO

------------------------------------------------------
-- 2. Batch logs table
------------------------------------------------------
IF OBJECT_ID('etl.log_batch', 'U') IS NOT NULL
	DROP TABLE etl.log_batch;

CREATE TABLE etl.log_batch (
	batch_id			BIGINT IDENTITY(1,1) NOT NULL,
	batch_start_time	DATETIME2(0) NOT NULL,
	batch_end_time		DATETIME2(0) NOT NULL,
	source				NVARCHAR(400),
	destination_table	SYSNAME NOT NULL,
	executed_by			SYSNAME NOT NULL,
	rows_loaded			BIGINT NOT NULL,
	valid_rows			BIGINT NOT NULL,
	non_valid_rows		BIGINT NOT NULL,
	non_valid_percent	DECIMAL(5,2) NOT NULL,
	duration_seconds	INT NOT NULL,
	status				VARCHAR(20) NOT NULL,
	error_message		NVARCHAR(4000) NULL
);
GO

------------------------------------------------------
-- 3. Quality errors logs table
------------------------------------------------------
IF OBJECT_ID('etl.log_quality_errors', 'U') IS NOT NULL
	DROP TABLE etl.log_quality_errors;

CREATE TABLE etl.log_quality_errors (
	table_name		SYSNAME NOT NULL,
	error_id		SMALLINT NOT NULL,
	log_timestamp	DATETIME2 NOT NULL DEFAULT(SYSDATETIME())
);
GO

------------------------------------------------------
-- 4. Data source tables
------------------------------------------------------
IF OBJECT_ID('etl.data_source', 'U') IS NOT NULL
	DROP TABLE etl.data_source;

CREATE TABLE etl.data_source (
	source_id			BIGINT IDENTITY(1,1) NOT NULL,
	path				NVARCHAR(4000) NOT NULL,
	destination_table	SYSNAME NOT NULL,
	delimeter			CHAR(1),
);