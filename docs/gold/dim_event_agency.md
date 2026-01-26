| Column Name | Data Type     | Description                        | Source Columns (with Schema)       | Transformation |
| ----------- | ------------- | ---------------------------------- | ---------------------------------- | -------------- |
| agency_id   | TINYINT       | Surrogate key for the event agency | `silver.ed_event_agency.agency_id` | None           |
| agency      | NVARCHAR(255) | Name of the agency                 | `silver.ed_event_agency.agency`    | None           |
