/*
=============================================================
Stored Procedure: Load fact_weather tabel to the gold layer
=============================================================
Script purpose:
	This script creates stored procedure which:
	1. truncate fact_weather table from gold layer
	2. tranform and clean data from silver layer with weather data
	3. load weather data from silver to gold layer

Procedure doesn't take any argument.

In order to use this procedure run:
EXEC etl.load_weather_to_gold

WARNING:
	Running this procedure will truncate fact_weather table in gold layer. 
	All data will be permanently deleted.
	Make sure there is no needed data in tables or it's backed up.
*/

USE NYC_taxi;
GO

CREATE OR ALTER PROCEDURE etl.load_weather_to_gold AS
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

		PRINT('>> STEP 1/2: Truncating table gold.fact_weather');

		TRUNCATE TABLE gold.fact_weather;

		PRINT('gold.fact_weather table has been truncated');

		------------------------------------------------------
		-- 2. Tranform & Insert
		------------------------------------------------------

		PRINT('');
		PRINT('>> STEP 2/2: Transform and load yellow taxi data into gold.fact_weather');

		SET @start_time = SYSDATETIME();

		INSERT INTO gold.fact_weather(
			weather_date_key
			,temperature_mean
			,temperature_mean_category
			,precipitation_total
			,precipitation_total_category
			,visibility
			,visibility_category
			,snow_depth
			,snow_depth_category
			,wind_speed_mean
			,wind_speed_mean_cateogry
			,is_fog
			,is_rain_or_drizzle
			,is_hail
			,is_thunder
			,is_tornado_or_funnel_cloud)
		SELECT
			w.weather_date_key									AS weather_date_key,
			w.temp_mean											AS temperature_mean,
			CASE 
				WHEN w.temp_mean < 0 THEN 'Freezing'
				WHEN w.temp_mean < 5 THEN 'Cold'
				WHEN w.temp_mean < 10 THEN 'Cool'
				WHEN w.temp_mean < 15 THEN 'Mild'
				WHEN w.temp_mean < 20 THEN 'Warm'
				WHEN w.temp_mean < 25 THEN 'Very Warm'
				WHEN w.temp_mean > 25 THEN 'Hot'
			END													AS temperature_mean_category,
			w.prcp_total										AS precipitation_total,
			CASE 
				WHEN w.prcp_total = 0 THEN 'Dry'
				WHEN w.prcp_total < 2.5 THEN 'Very light'
				WHEN w.prcp_total < 10 THEN 'Light'
				WHEN w.prcp_total < 25 THEN 'Moderate'
				WHEN w.prcp_total < 50 THEN 'Heavy'
				WHEN w.prcp_total >= 50 THEN 'Extreme'
			END													AS precipitation_total_category,
			w.visibility										AS visibility,
			CASE 
				WHEN w.visibility < 7 THEN 'Very low'
				WHEN w.visibility < 10 THEN 'Low'
				WHEN w.visibility < 14 THEN 'Moderate'
				WHEN w.visibility >= 14 THEN 'High'
			END													AS visibility_category,
			w.snow_dp											AS snow_depth,
			CASE 
				WHEN w.snow_dp = 0 THEN 'No snow'
				WHEN w.snow_dp < 30 THEN 'Light snow'
				WHEN w.snow_dp < 50 THEN 'Moderate snow'
				WHEN w.snow_dp >= 50 THEN 'Heavy snow'
			END													AS snow_depth_category,
			w.wind_s_mean										AS wind_speed_mean,
			CASE 
				WHEN w.wind_s_mean < 5 THEN 'Calm'
				WHEN w.wind_s_mean < 15 THEN 'Light wind'
				WHEN w.wind_s_mean < 30 THEN 'Moderate wind'
				WHEN w.wind_s_mean < 50 THEN 'Strong wind'
				WHEN w.wind_s_mean >= 50 THEN 'Very strong wind'
			END													AS wind_speed_mean_category,
			IIF(w.fog = 1, 'Yes', 'No')							AS is_fog,
			IIF(w.rain_or_drizzle = 1, 'Yes', 'No')				AS is_rain_or_drizzle,
			IIF(w.hail = 1, 'Yes', 'No')						AS is_hail,
			IIF(w.thunder = 1, 'Yes', 'No')						AS is_thunder,
			IIF(w.tornado_or_funnel_cloud = 1, 'Yes', 'No')		AS is_tornado_or_funnel_cloud
		FROM silver.wd_weather w

		SELECT @rows_loaded = COUNT(*) FROM gold.fact_weather;

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
			'silver.wd_weather',
			'gold.fact_weather',
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

		PRINT('Loading gold.fact_wetaher completed!');
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
			'silver.wd_weather',
			'gold.fact_weather',
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

	