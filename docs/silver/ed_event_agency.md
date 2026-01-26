| Column Name | Data Type     | Description                             | Source                          | Transformations                                                                 |
| ----------- | ------------- | --------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------- |
| agency_id   | TINYINT       | Unique identifier for each agency       | Auto-generated in Silver        | Identity column, starts from 1                                                  |
| agency_name | NVARCHAR(255) | Name of the agency organizing the event | `bronze.ed_events.event_agency` | Trim whitespace, remove double quotes (`"`) using `REPLACE(TRIM(...), '"', '')` |
