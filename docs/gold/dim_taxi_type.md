| Column Name  | Data Type    | Description                          | Source Columns (with Schema)                      | Transformation |
| ------------ | ------------ | ------------------------------------ | ------------------------------------------------- | -------------- |
| taxi_type_id | TINYINT      | Unique identifier for each taxi type | Manual insert (values 1–4)                        | None           |
| taxi_type    | NVARCHAR(20) | Descriptive name of the taxi type    | Manual insert ('Yellow', 'Green', 'Uber', 'Lyft') | None           |
