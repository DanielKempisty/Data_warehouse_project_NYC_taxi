| Column Name  | Data Type     | Description                                             | Source Columns (with Schema)  | Transformation                     |
| ------------ | ------------- | ------------------------------------------------------- | ----------------------------- | ---------------------------------- |
| date_key     | BIGINT        | Surrogate key for the date                              | `silver.hd_date.date_key`     | None                               |
| full_date    | DATE          | Actual calendar date                                    | `silver.hd_date.full_date`    | None                               |
| quarter      | TINYINT       | Calendar quarter of the year (1–4)                      | `silver.hd_date.quarter`      | None                               |
| month        | TINYINT       | Month of the year (1–12)                                | `silver.hd_date.month`        | None                               |
| day          | TINYINT       | Day of the month (1–31)                                 | `silver.hd_date.day`          | None                               |
| is_weekend   | VARCHAR(3)    | Flag indicating if the day is a weekend (Yes/No)        | `silver.hd_date.is_weekend`   | `IIF(is_weekend = 1, 'Yes', 'No')` |
| is_holiday   | VARCHAR(3)    | Flag indicating if the day is a public holiday (Yes/No) | `silver.hd_date.is_holiday`   | `IIF(is_holiday = 1, 'Yes', 'No')` |
| holiday_name | NVARCHAR(255) | Name of the holiday if applicable                       | `silver.hd_date.holiday_name` | None                               |
