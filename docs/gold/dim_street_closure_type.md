| Column Name            | Data Type     | Description                                  | Source Columns (with Schema)                           | Transformation |
| ---------------------- | ------------- | -------------------------------------------- | ------------------------------------------------------ | -------------- |
| street_closure_type_id | TINYINT       | Surrogate key for the type of street closure | `silver.ed_street_closure_type.street_closure_type_id` | None           |
| street_closure_type    | NVARCHAR(255) | Name/description of the street closure type  | `silver.ed_street_closure_type.street_closure_type`    | None           |
