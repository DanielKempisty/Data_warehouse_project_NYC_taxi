CREATE OR ALTER FUNCTION silver.time_interval(@dt DATETIME)
RETURNS TABLE
AS	
RETURN (
		SELECT
			CAST(			-- assigning pick up time to proper period of time for timeline analysis
				DATEADD(
					MINUTE,
					DATEDIFF(MINUTE, 0, @dt) / 60 * 60,
					0
			) AS TIME(0)) AS time_interval
);
GO