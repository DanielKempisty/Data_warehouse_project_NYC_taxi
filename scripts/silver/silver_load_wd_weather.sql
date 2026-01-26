/*
=============================================================
Stored Procedure: Load weather data to the silver layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate table silver.wd_weather from silver layer
	2. tranform and clean data from bronze layer with events data
	3. load events data from bronze to table from silver layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_weather_data_to_silver

WARNING:
	Running this procedure will truncate silver.wd_weather table in silver layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_weather_data_to_silver AS
BEGIN	

	SET NOCOUNT ON;

	DECLARE @start_time DATETIME2(0), @end_time DATETIME2(0), @rows_count BIGINT; 

	BEGIN TRY

		BEGIN TRAN;

		SET @start_time = SYSDATETIME();

		------------------------------------------------------
		-- 1. Truncate existing table
		------------------------------------------------------

		PRINT('>> STEP 1/2: Truncating table silver.wd_weather');

		TRUNCATE TABLE silver.wd_weather;

		PRINT('silver.wd_weather table has been truncated');

		------------------------------------------------------
		-- 2. Clean & transform data
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load data into silver.wd_weather');

		WITH transf_weather_1 AS(
			SELECT DISTINCT 
				REPLACE(TRIM(station_id), '"', '')							AS station_id,
				REPLACE(TRIM(station_name), '"', '')						AS station_name,
				REPLACE(TRIM(date), '"', '')								AS weather_date,
				REPLACE(TRIM(temp_mean), '"', '')							AS temp_mean,
				REPLACE(TRIM(temp_max), '"', '')							AS temp_max,
				REPLACE(TRIM(temp_min), '"', '')							AS temp_min,
				REPLACE(TRIM(prcp_total), '"', '')							AS prcp_total,
				REPLACE(TRIM(visibility), '"', '')							AS visibility,
				REPLACE(TRIM(snow_dp), '"', '')								AS snow_dp,
				REPLACE(TRIM(wind_s_mean), '"', '')							AS wind_s_mean,
				REPLACE(TRIM(wind_s_max), '"', '')							AS wind_s_max,
				REPLACE(TRIM(wind_g_max), '"', '')							AS wind_g_max,
				REPLACE(TRIM(dew_p), '"', '')								AS dew_p,
				REPLACE(TRIM(sl_pressure), '"', '')							AS sl_pressure,
				REPLACE(TRIM(st_pressure), '"', '')							AS st_pressure,
				REPLACE(TRIM(phenomena), '"', '')							AS phenomena		
			FROM bronze.wd_weather),
		transf_weather_2 AS(
			SELECT
			tw1.station_id,
			tw1.station_name,
			tw1.weather_date,
			dk.date_key													AS weather_date_key,
			IIF(tw1.temp_mean = '9999.9', NULL , tw1.temp_mean)			AS temp_mean,
			IIF(tw1.temp_max = '9999.9', NULL , tw1.temp_max)			AS temp_max,
			IIF(tw1.temp_min = '9999.9', NULL , tw1.temp_min)			AS temp_min,
			IIF(tw1.prcp_total = '99.99', '0', tw1.prcp_total)			AS prcp_total,
			IIF(tw1.visibility = '999.9', NULL , tw1.visibility)		AS visibility,
			IIF(tw1.snow_dp = '999.9', '0', tw1.snow_dp)				AS snow_dp,
			IIF(tw1.wind_s_mean = '999.9', NULL , tw1.wind_s_mean)		AS wind_s_mean,
			IIF(tw1.wind_s_max = '999.9', NULL , tw1.wind_s_max)		AS wind_s_max,
			IIF(tw1.wind_g_max = '999.9', NULL , tw1.wind_g_max)		AS wind_g_max,
			IIF(tw1.dew_p = '9999.9', NULL, tw1.dew_p)					AS dew_p,
			IIF(tw1.sl_pressure = '9999.9', NULL , tw1.sl_pressure)		AS sl_pressure,
			IIF(tw1.st_pressure = '9999.9', NULL , tw1.st_pressure)		AS st_pressure,
			IIF(SUBSTRING(tw1.phenomena, 1, 1) = '1', 1, 0)				AS fog,
			IIF(SUBSTRING(tw1.phenomena, 2, 1) = '1', 1, 0)				AS rain_or_drizzle,
			IIF(SUBSTRING(tw1.phenomena, 3, 1) = '1', 1, 0)				AS snow_or_ice,
			IIF(SUBSTRING(tw1.phenomena, 4, 1) = '1', 1, 0)				AS hail,
			IIF(SUBSTRING(tw1.phenomena, 5, 1) = '1', 1, 0)				AS thunder,
			IIF(SUBSTRING(tw1.phenomena, 6, 1) = '1', 1, 0)				AS tornado_or_funnel_cloud
		FROM transf_weather_1 tw1
			OUTER APPLY silver.create_date_key(tw1.weather_date) dk
		)
		------------------------------------------------------
		-- 3. Insert to silver.wd_weather table
		------------------------------------------------------

		INSERT INTO silver.wd_weather(
			station_id,
			station_name,
			weather_date,
			weather_date_key,
			temp_mean,
			temp_max,
			temp_min,
			prcp_total,
			visibility,
			snow_dp,
			wind_s_mean,
			wind_s_max,
			wind_g_max,
			dew_p,
			sl_pressure,
			st_pressure,
			fog,
			rain_or_drizzle,
			snow_or_ice_pellets,
			hail,
			thunder,
			tornado_or_funnel_cloud
			)

		SELECT
			tw2.station_id,
			tw2.station_name,
			tw2.weather_date,
			tw2.weather_date_key,
			(tw2.temp_mean - 32.0) * (5.0 / 9.0)									AS temp_mean, -- converting from Fahrenheit to Celcius
			(tw2.temp_max - 32.0) * (5.0 / 9.0)										AS temp_max, -- converting from Fahrenheit to Celcius
			(tw2.temp_min - 32.0) * (5.0 / 9.0)										AS temp_min, -- converting from Fahrenheit to Celcius
			tw2.prcp_total * 25.4													AS prcp_total, -- converting from inches to milimeters
			CAST(tw2.visibility AS NUMERIC) * 1.609344								AS visibility, -- converting from miles to kilometers
			tw2.snow_dp * 25.4														AS snow_dp, -- converting from inches to milimiters
			CAST(tw2.wind_s_mean AS NUMERIC) * 1.852								AS wind_s_mean, -- converting from knots to km/h
			CAST(tw2.wind_s_max AS NUMERIC) * 1.852									AS wind_s_max, -- converting from knots to km/h
			CAST(tw2.wind_g_max AS NUMERIC) * 1.852									AS wind_g_max, -- converting from knots to km/h
			(tw2.dew_p - 32.0) * (5.0 / 9.0)										AS dew_p, -- converting from Fahrenheit to Celcius
			tw2.sl_pressure,
			IIF(tw2.st_pressure < 100.0, tw2.st_pressure + 1000.0, tw2.st_pressure)	AS st_pressure,
			tw2.fog,
			tw2.rain_or_drizzle,
			tw2.snow_or_ice,
			tw2.hail,
			tw2.thunder,
			tw2.tornado_or_funnel_cloud
		FROM transf_weather_2 tw2
		
		------------------------------------------------------
		-- 4. End stats & messages
		------------------------------------------------------
		SELECT @rows_count = COUNT(*) FROM silver.wd_weather;

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
			'bronze.wd_weather',
			'silver.wd_weather',
			ORIGINAL_LOGIN(),
			@rows_count,
			@rows_count,
			@rows_count,
			0,
			DATEDIFF(SECOND, @start_time, @end_time),
			'success'
		);

		PRINT('Loading silver.wd_weather completed!');
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
			'bronze.wd_weather',
			'silver.wd_weather',
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

 

