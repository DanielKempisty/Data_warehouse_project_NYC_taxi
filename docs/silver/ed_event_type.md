| Column Name   | Data Type     | Description                           | Source                        | Transformations                                                                    |
| ------------- | ------------- | ------------------------------------- | ----------------------------- | ---------------------------------------------------------------------------------- |
| event_type_id | TINYINT       | Unique identifier for each event type | Auto-generated in Silver      | Identity column, starts from 1                                                     |
| event_type    | NVARCHAR(255) | Name or type of the event             | `bronze.ed_events.event_type` | Trim whitespace and remove double quotes (`"`) using `REPLACE(TRIM(...), '"', '')` |
