| Column Name  | Data Type     | Description                                        | Source            | Transformations                                             |
| ------------ | ------------- | -------------------------------------------------- | ----------------- | ----------------------------------------------------------- |
| location_id  | SMALLINT      | Unique identifier for the taxi zone                | bronze.taxi_zones | None                                                        |
| borough_id   | TINYINT       | Borough identifier (1–10, e.g., Bronx=1)           | bronze.taxi_zones | Map string borough to ID using lookup, ensure valid values  |
| zone         | NVARCHAR(255) | Name of the taxi zone                              | bronze.taxi_zones | Trim, proper case formatting                                |
| service_zone | NVARCHAR(20)  | Service zone category (e.g., Boro, Airport)        | bronze.taxi_zones | Standardize values, remove nulls                            |
| is_cbd       | BIT           | Indicates if the zone is Central Business District | ETL derived       | `IIF(location_id IN (...), 1, 0)` |
| is_airport   | BIT           | Indicates if the zone is an airport                | ETL derived       | `IIF(location_id IN (...), 1, 0)`                  |
