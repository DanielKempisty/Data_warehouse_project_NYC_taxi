| Column Name  | Data Type    | Description                                           | Source Columns (with Schema)  | Transformation                     |
| ------------ | ------------ | ----------------------------------------------------- | ----------------------------- | ---------------------------------- |
| borough_id   | TINYINT      | Unique identifier for each borough                    | `silver.borough.borough_id`   | None                               |
| borough_name | NVARCHAR(50) | Name of the borough                                   | `silver.borough.borough_name` | None                               |
| is_airport   | VARCHAR(3)   | Indicates if the borough contains an airport (Yes/No) | `silver.borough.is_airport`   | `IIF(is_airport = 1, 'Yes', 'No')` |
