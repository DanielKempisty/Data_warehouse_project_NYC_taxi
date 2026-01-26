| Column Name     | Data Type    | Description                                                                               | Source    | Transformation |
| --------------- | ------------ | ----------------------------------------------------------------------------------------- | --------- | -------------- |
| station_id      | NVARCHAR(50) | Unique identifier for the weather station.                                                | CSV files | None           |
| date            | NVARCHAR(50) | Observation date of the weather data.                                                     | CSV files | None           |
| latitude        | NVARCHAR(50) | Latitude coordinate of the weather station.                                               | CSV files | None           |
| longitude       | NVARCHAR(50) | Longitude coordinate of the weather station.                                              | CSV files | None           |
| elevation       | NVARCHAR(50) | Elevation of the weather station above sea level (in meters or feet as in source).        | CSV files | None           |
| station_name    | NVARCHAR(50) | Name of the weather station.                                                              | CSV files | None           |
| temp_mean       | NVARCHAR(50) | Average temperature for the day (°F).                           | CSV files | None           |
| temp_mean_att   | NVARCHAR(50) | Flag indicating if temp_mean is estimated or missing.                                     | CSV files | None           |
| dew_p           | NVARCHAR(50) | Average dew point for the day (°F).                             | CSV files | None           |
| dew_p_att       | NVARCHAR(50) | Flag indicating if dew_p is estimated or missing.                                         | CSV files | None           |
| sl_pressure     | NVARCHAR(50) | Sea-level adjusted atmospheric pressure.                                                  | CSV files | None           |
| sl_pressure_att | NVARCHAR(50) | Flag indicating if sl_pressure is estimated or missing.                                   | CSV files | None           |
| st_pressure     | NVARCHAR(50) | Station-level atmospheric pressure.                                                       | CSV files | None           |
| st_pressure_att | NVARCHAR(50) | Flag indicating if st_pressure is estimated or missing.                                   | CSV files | None           |
| visibility      | NVARCHAR(50) | Average visibility distance during the day (in miles).                              | CSV files | None           |
| visibility_att  | NVARCHAR(50) | Flag indicating if visibility is estimated or missing.                                    | CSV files | None           |
| wind_s_mean     | NVARCHAR(50) | Average wind speed at the station.                                                        | CSV files | None           |
| wind_s_mean_att | NVARCHAR(50) | Flag indicating if wind_s_mean is estimated or missing.                                   | CSV files | None           |
| wind_s_max      | NVARCHAR(50) | Maximum sustained wind speed observed during the day.                                     | CSV files | None           |
| wind_g_max      | NVARCHAR(50) | Maximum wind gust observed during the day.                                                | CSV files | None           |
| temp_max        | NVARCHAR(50) | Maximum temperature observed during the day.                                              | CSV files | None           |
| temp_max_att    | NVARCHAR(50) | Flag indicating if temp_max is estimated or missing.                                      | CSV files | None           |
| temp_min        | NVARCHAR(50) | Minimum temperature observed during the day.                                              | CSV files | None           |
| temp_min_att    | NVARCHAR(50) | Flag indicating if temp_min is estimated or missing.                                      | CSV files | None           |
| prcp_total      | NVARCHAR(50) | Total precipitation (rain, snow, etc.) for the day.                                       | CSV files | None           |
| prcp_total_att  | NVARCHAR(50) | Flag indicating if prcp_total is estimated or missing.                                    | CSV files | None           |
| snow_dp         | NVARCHAR(50) | Snow depth recorded at the station.                                                       | CSV files | None           |
| phenomena       | NVARCHAR(50) | Textual description of weather phenomena observed (fog, rain, snow, hail, thunder, etc.). | CSV files | None           |
