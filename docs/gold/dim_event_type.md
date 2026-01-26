| Column Name   | Data Type     | Description                         | Source Columns (with Schema)         | Transformation |
| ------------- | ------------- | ----------------------------------- | ------------------------------------ | -------------- |
| event_type_id | TINYINT       | Surrogate key for the type of event | `silver.ed_event_type.event_type_id` | None           |
| event_type    | NVARCHAR(255) | Name/description of the event type  | `silver.ed_event_type.event_type`    | None           |
