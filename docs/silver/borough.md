| Column Name  | Data Type    | Description                    | Source             | Transformations                                    |
| ------------ | ------------ | ------------------------------ | ------------------ | -------------------------------------------------- |
| borough_id   | TINYINT      | Surrogate key for borough      | Manual / Hardcoded | Assigned manually (1–10)                           |
| borough_name | NVARCHAR(20) | Name of the borough or airport | Manual / Hardcoded | Trimmed & standardized manually                    |
| is_airport   | TINYINT      | Flag if location is an airport | Manual / Hardcoded | 1 = airport (EWR, JFK, LaGuardia), 0 = non-airport |
