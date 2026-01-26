/*
=============================================================
Create functions used in silver layer
=============================================================
Script purpose:
	This script creates function used in silver layer.
	Three of them validate data quality (1-3) and one creates data key (4).
*/

USE NYC_taxi;
GO

------------------------------------------------------
-- 1. Validate yellow and green taxi data function
------------------------------------------------------
CREATE OR ALTER FUNCTION silver.validate_yellow_green_records(
								@trip_distance	DECIMAL(8,2), 
								@total_amount	DECIMAL(8,2),
								@pu_datetime	DATETIME,
								@do_datetime	DATETIME,
								@total_diff		DECIMAL(8,2),
								@vendor_id		SMALLINT)
RETURNS TABLE
AS
RETURN
	SELECT
		CASE	-- validating records quality
			WHEN @trip_distance <= 0 THEN 1
			WHEN @total_amount <= 0 THEN 2
			WHEN DATEDIFF(SECOND, @pu_datetime, @do_datetime) <= 0 THEN 3
			WHEN @total_diff <> 0 THEN 4
			WHEN @vendor_id NOT IN (1, 2) THEN 5
			WHEN 
				@pu_datetime < '2024-01-01' 
				OR @pu_datetime > '2024-12-31'
				OR @do_datetime < '2024-01-01' 
				OR @do_datetime > '2024-12-31' 
				OR @do_datetime IS NULL
				OR @pu_datetime  IS NULL
				THEN 6
			WHEN DATEDIFF(HOUR, @pu_datetime, @do_datetime) > 6 THEN 7
			WHEN IIF(
					DATEDIFF(SECOND, @pu_datetime, @do_datetime) > 0, 
					@trip_distance / CAST(DATEDIFF(SECOND, @pu_datetime, @do_datetime) AS DECIMAL(10, 1)) * 3600, 
					0) 
				>= 150 THEN 8
			ELSE 0
		END AS reject_id;
GO


------------------------------------------------------
-- 2. Validate for-hire taxi data function
------------------------------------------------------
CREATE OR ALTER FUNCTION silver.validate_for_hire_records(
								@trip_distance	DECIMAL(8,2), 
								@total_amount	DECIMAL(8,2),
								@pu_datetime	DATETIME,
								@do_datetime	DATETIME,
								@base_passenger_fee DECIMAL(8,2),
								@driver_pay DECIMAL(8,2),
								@tolls_amount DECIMAL(8,2),
								@congestion_surcharge DECIMAL(8,2),
								@airport_fee DECIMAL(8,2),
								@bcf_fee DECIMAL(8,2),
								@sales_tax DECIMAL(8,2),
								@tip_amount DECIMAL(8,2)
							)
RETURNS TABLE
AS
RETURN
	SELECT
		CASE	-- validating records quality
			WHEN @trip_distance <= 0 THEN 1
			WHEN @total_amount <= 0 THEN 2
			WHEN DATEDIFF(SECOND, @pu_datetime, @do_datetime) <= 0 THEN 3
			WHEN 
				@pu_datetime < '2024-01-01' 
				OR @pu_datetime > '2024-12-31'
				OR @do_datetime < '2024-01-01' 
				OR @do_datetime > '2024-12-31' 
				OR @do_datetime IS NULL
				OR @pu_datetime  IS NULL
				THEN 6
			WHEN DATEDIFF(HOUR, @pu_datetime, @do_datetime) > 6 THEN 7
			WHEN IIF(
					DATEDIFF(SECOND, @pu_datetime, @do_datetime) > 0, 
					@trip_distance / CAST(DATEDIFF(SECOND, @pu_datetime, @do_datetime) AS DECIMAL(10, 1)) * 3600, 
					0) 
				>= 150 THEN 8
			
			WHEN 
				@base_passenger_fee < 0 
				OR @driver_pay < 0 
				OR @tolls_amount < 0 
				OR @congestion_surcharge < 0 
				OR @airport_fee < 0 
				OR @bcf_fee < 0 
				OR @sales_tax < 0 
				OR @tip_amount < 0 
				THEN 9
			ELSE 0	
		END AS reject_id;
GO


------------------------------------------------------
-- 3. Validate events data function
------------------------------------------------------
CREATE OR ALTER FUNCTION silver.validate_events_records(
								@start_datetime	DATETIME2(0), 
								@end_datetime	DATETIME2(0)
							)
RETURNS TABLE
AS
RETURN
	SELECT
		CASE	-- validating records quality
			WHEN @start_datetime >= @end_datetime THEN 10
			WHEN 
				(@start_datetime < '2024-01-01' 
				OR @start_datetime > '2024-12-31')
				AND
				(@end_datetime< '2024-01-01' 
				OR @end_datetime > '2024-12-31' )
				THEN 11
			ELSE 0
			END	AS reject_id;	
GO


------------------------------------------------------
-- 4. Create data key function 
------------------------------------------------------
CREATE OR ALTER FUNCTION silver.create_date_key(
								@date	DATE
							)
RETURNS TABLE
AS
RETURN
	SELECT
		CASE	
			WHEN @date >= '2025-01-01' THEN -1
			WHEN @date <= '2023-12-31' THEN -1
			ELSE YEAR(@date) * 10000 + MONTH(@date) * 100 + DAY(@date)
		END	AS date_key;	

			
