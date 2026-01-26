| Column Name        | Data Type   | Description                            | Source Columns (with Schema) | Transformation |
| ------------------ | ----------- | -------------------------------------- | ---------------------------- | -------------- |
| distance_bucket_id | TINYINT     | Surrogate key for the distance bucket  | `manual` (hardcoded values)  | None           |
| distance_bucket    | NVARCHAR(5) | Label for distance range (miles or km) | `manual` (hardcoded values)  | None           |
