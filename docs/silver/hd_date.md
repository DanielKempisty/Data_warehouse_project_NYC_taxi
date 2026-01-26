| Column Name  | Data Type     | Description                   | Source                            | Transformations                                     |
| ------------ | ------------- | ----------------------------- | --------------------------------- | --------------------------------------------------- |
| date_key     | BIGINT        | Surrogate key for the date    | `calendar.lu_date` (generated)    | Convert `YYYY-MM-DD` to `YYYYMMDD` bigint           |
| full_date    | DATE          | Full calendar date            | `calendar.lu_date`                | Generated via CTE `calendar`                        |
| quarter      | TINYINT       | Quarter of the year           | `calendar.lu_date`                | `DATEPART(QQ, full_date)`                           |
| month        | TINYINT       | Month of the year             | `calendar.lu_date`                | `MONTH(full_date)`                                  |
| day          | TINYINT       | Day of the month              | `calendar.lu_date`                | `DAY(full_date)`                                    |
| is_weekend   | BIT           | Flag if date is weekend       | `calendar.lu_date`                | `IIF(DATEPART(WEEKDAY, full_date) IN (7, 1), 1, 0)` |
| is_holiday   | BIT           | Flag if date is a holiday     | `bronze.hd_holidays.holiday_date` | LEFT JOIN with `calendar`; 1 if match, 0 otherwise  |
| holiday_name | NVARCHAR(255) | Name of holiday if applicable | `bronze.hd_holidays.holiday_name` | LEFT JOIN with `calendar`; NULL if not holiday      |
