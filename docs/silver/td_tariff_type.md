| Column Name    | Data Type    | Description                                        | Source | Transformations                                                                 |
| -------------- | ------------ | -------------------------------------------------- | ------ | ------------------------------------------------------------------------------- |
| tariff_type_id | TINYINT      | Identifier of the tariff type applied to the trip. | Manual | Manually populated with fixed tariff identifiers based on TLC fare definitions. |
| tariff_type    | NVARCHAR(30) | Descriptive name of the tariff type.               | Manual | Manually populated with standardized tariff type labels.                        |
