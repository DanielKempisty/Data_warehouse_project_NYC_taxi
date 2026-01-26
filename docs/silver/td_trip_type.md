| Column Name  | Data Type    | Description                         | Source | Transformations                                                         |
| ------------ | ------------ | ----------------------------------- | ------ | ----------------------------------------------------------------------- |
| trip_type_id | TINYINT      | Unique identifier of the trip type. | Manual | Manually populated with fixed IDs for street-hail (1) and dispatch (2). |
| trip_type    | NVARCHAR(20) | Descriptive name of the trip type.  | Manual | Manually populated; standardized string labels for trip types.          |
