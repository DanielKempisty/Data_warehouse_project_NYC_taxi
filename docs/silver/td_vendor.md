| Column Name | Data Type    | Description                      | Source        | Transformations                          |
| ----------- | ------------ | -------------------------------- | ------------- | ---------------------------------------- |
| vendor_id   | SMALLINT     | Unique identifier for the vendor | bronze.vendor | None                                     |
| vendor_name | NVARCHAR(50) | Vendor’s full name               | bronze.vendor | Trim spaces, proper casing, remove nulls |
