| Column Name | Data Type    | Description                                   | Source | Transformations                                                                                       |
| ----------- | ------------ | --------------------------------------------- | ------ | ----------------------------------------------------------------------------------------------------- |
| vendor_id   | SMALLINT     | Unique identifier of the taxi service vendor. | Manual | Manually populated with fixed, predefined values; includes a default `-1` record for unknown vendors. |
| vendor_name | NVARCHAR(50) | Name of the taxi service vendor.              | Manual | Manually populated; descriptive vendor names assigned to each vendor identifier.                      |
