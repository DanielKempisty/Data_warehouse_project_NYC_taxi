| Column Name        | Data Type     | Description                                                                | Source             | Transformations                        |
| ------------------ | ------------- | -------------------------------------------------------------------------- | ------------------ | -------------------------------------- |
| reject_id          | TINYINT       | Unique identifier for rejection code                                       | Manual / Hardcoded | Manually assigned, values from 0 to 11 |
| reject_description | NVARCHAR(255) | Description of the rule under which a record is rejected in ETL validation | Manual / Hardcoded | Manually assigned for each `reject_id` |
