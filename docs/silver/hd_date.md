| Column Name  | Data Type     | Description                  | Source                            | Transformations                                                        |
| ------------ | ------------- | ---------------------------- | --------------------------------- | ---------------------------------------------------------------------- |
| date_key     | BIGINT        | Surrogate key for the date   | Generated                         | `CAST(REPLACE(lu_date, '-', '') AS BIGINT)`; -1 for dates outside 2024 |
| full_date    | DATE          | Actual date                  | bronze.hd_holidays + calendar CTE | Direct from calendar CTE                                               |
| quarter      | INT           | Quarter of the year          | Generated                         | `DATEPART(QQ, lu_date)`                                                |
| month        | INT           | Month number                 | Generated                         | `MONTH(lu_date)`                                                       |
| day          | INT           | Day of month                 | Generated                         | `DAY(lu_date)`                                                         |
| is_weekend   | BIT           | Flag if date is weekend      | Generated                         | `IIF(DATEPART(WEEKDAY, lu_date) IN (1,7), 1, 0)`                       |
| is_holiday   | BIT           | Flag if date is a holiday    | bronze.hd_holidays                | `IIF(holiday_date IS NOT NULL, 1, 0)`                                  |
| holiday_name | NVARCHAR(100) | Name of holiday if it exists | bronze.hd_holidays                | Direct join from bronze.hd_holidays                                    |
