| Column Name             | Data Type     | Description                    | Source                                 | Transformations                                             |
| ----------------------- | ------------- | ------------------------------ | -------------------------------------- | ----------------------------------------------------------- |
| station_id              | BIGINT        | Unique station ID              | `bronze.wd_weather.station_id`         | Trim, remove quotes                                         |
| station_name            | NVARCHAR(255) | Name of the station            | `bronze.wd_weather.station_name`       | Trim, remove quotes                                         |
| weather_date            | DATE          | Observation date               | `bronze.wd_weather.date`               | Trim, remove quotes, convert to DATE                        |
| weather_date_key        | BIGINT        | Surrogate key for weather_date | `silver.create_date_key(weather_date)` | Generated key                                               |
| temp_mean               | DECIMAL(7,2)  | Mean temperature in °C         | `bronze.wd_weather.temp_mean`          | Replace `9999.9` with NULL; convert F → C `(value-32)*5/9`  |
| temp_max                | DECIMAL(7,2)  | Max temperature in °C          | `bronze.wd_weather.temp_max`           | Replace `9999.9` with NULL; convert F → C                   |
| temp_min                | DECIMAL(7,2)  | Min temperature in °C          | `bronze.wd_weather.temp_min`           | Replace `9999.9` with NULL; convert F → C                   |
| prcp_total              | DECIMAL(7,2)  | Total precipitation in mm      | `bronze.wd_weather.prcp_total`         | Replace `99.99` with 0; convert inches → mm (`*25.4`)       |
| visibility              | DECIMAL(7,2)  | Visibility in km               | `bronze.wd_weather.visibility`         | Replace `999.9` with NULL; convert miles → km (`*1.609344`) |
| snow_dp                 | DECIMAL(7,2)  | Snow depth in mm               | `bronze.wd_weather.snow_dp`            | Replace `999.9` with 0; convert inches → mm                 |
| wind_s_mean             | DECIMAL(7,2)  | Mean wind speed in km/h        | `bronze.wd_weather.wind_s_mean`        | Replace `999.9` with NULL; convert knots → km/h (`*1.852`)  |
| wind_s_max              | DECIMAL(7,2)  | Max sustained wind in km/h     | `bronze.wd_weather.wind_s_max`         | Replace `999.9` with NULL; convert knots → km/h             |
| wind_g_max              | DECIMAL(7,2)  | Max wind gust in km/h          | `bronze.wd_weather.wind_g_max`         | Replace `999.9` with NULL; convert knots → km/h             |
| dew_p                   | DECIMAL(7,2)  | Dew point in °C                | `bronze.wd_weather.dew_p`              | Replace `9999.9` with NULL; convert F → C                   |
| sl_pressure             | DECIMAL(7,2)  | Sea-level pressure             | `bronze.wd_weather.sl_pressure`        | Keep original                                               |
| st_pressure             | DECIMAL(7,2)  | Station pressure               | `bronze.wd_weather.st_pressure`        | If <100, add 1000                                           |
| fog                     | BIT           | Fog observed                   | `bronze.wd_weather.phenomena`          | Substring(1,1) = '1' → 1, else 0                            |
| rain_or_drizzle         | BIT           | Rain or drizzle observed       | `bronze.wd_weather.phenomena`          | Substring(2,1) = '1' → 1, else 0                            |
| snow_or_ice_pellets     | BIT           | Snow/ice pellets observed      | `bronze.wd_weather.phenomena`          | Substring(3,1) = '1' → 1, else 0                            |
| hail                    | BIT           | Hail observed                  | `bronze.wd_weather.phenomena`          | Substring(4,1) = '1' → 1, else 0                            |
| thunder                 | BIT           | Thunder observed               | `bronze.wd_weather.phenomena`          | Substring(5,1) = '1' → 1, else 0                            |
| tornado_or_funnel_cloud | BIT           | Tornado/funnel cloud observed  | `bronze.wd_weather.phenomena`          | Substring(6,1) = '1' → 1, else 0                            |
