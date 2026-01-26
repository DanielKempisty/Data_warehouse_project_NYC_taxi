| Column Name   | Data Type     | Description                                              | Source                        | Transformations                         |
| ------------- | ------------- | -------------------------------------------------------- | ----------------------------- | --------------------------------------- |
| table_name    | SYSNAME       | Name of the table on which the quality check applies     | Manual / Hardcoded            | None                                    |
| condition     | NVARCHAR(255) | The logical condition that must hold true for valid data | Manual / Hardcoded            | Stored as SQL expression for validation |
| error_id      | SMALLINT      | Unique identifier for the QC rule                        | Manual / Hardcoded / Identity | Auto-increment starting at 101          |
| error_message | NVARCHAR(255) | Description of the error if the QC condition fails       | Manual / Hardcoded            | None                                    |
