| Column Name  | Data Type     | Description                                                                                 | Source    | Transformation |
| ------------ | ------------- | ------------------------------------------------------------------------------------------- | --------- | -------------- |
| location_id  | INT           | Unique identifier for the taxi zone or location within NYC used for pick-ups and drop-offs. | CSV files | None           |
| borough      | NVARCHAR(30)  | Name of the borough where the taxi zone is located (e.g., Manhattan, Brooklyn).             | CSV files | None           |
| zone         | NVARCHAR(255) | Name of the specific taxi zone or neighborhood (e.g., Upper East Side, JFK Airport).        | CSV files | None           |
| service_zone | NVARCHAR(20)  | Service classification for the zone (e.g., Boro, Airport, Downtown).                        | CSV files | None           |
