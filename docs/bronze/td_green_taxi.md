| Column Name           | Data Type     | Description                   | Source   | Transformations |
| --------------------- | ------------- | ----------------------------- | ---------| --------------- |
| vendor_id             | INT           | Taxi system vendor identifier | CSV file | None            |
| pu_datetime           | DATETIME2     | Pickup date and time          | CSV file | None            |
| do_datetime           | DATETIME2     | Drop-off date and time        | CSV file | None            |
| store_and_fwd         | NVARCHAR(20)  | Store-and-forward trip flag   | CSV file | None            |
| tariff_type           | DECIMAL(18,4) | Applied rate code             | CSV file | None            |
| pu_location_id        | INT           | Pickup taxi zone identifier   | CSV file | None            |
| do_location_id        | INT           | Drop-off taxi zone identifier | CSV file | None            |
| passenger_cnt         | DECIMAL(18,4) | Number of passengers          | CSV file | None            |
| trip_distance         | DECIMAL(18,4) | Trip distance in miles        | CSV file | None            |
| fare_amount           | DECIMAL(18,4) | Base fare amount              | CSV file | None            |
| extra                 | DECIMAL(18,4) | Additional charges            | CSV file | None            |
| mta_tax               | DECIMAL(18,4) | MTA tax amount                | CSV file | None            |
| tip_amount            | DECIMAL(18,4) | Tip amount                    | CSV file | None            |
| tolls_amount          | DECIMAL(18,4) | Toll charges                  | CSV file | None            |
| ehail_fee             | DECIMAL(18,4) | E-hail fee                    | CSV file | None            |
| improvement_surcharge | DECIMAL(18,4) | Improvement surcharge         | CSV file | None            |
| total_amount          | DECIMAL(18,4) | Total trip amount             | CSV file | None            |
| payment_type          | DECIMAL(18,4) | Payment method                | CSV file | None            |
| trip_type             | DECIMAL(18,4) | Trip type indicator           | CSV file | None            |
| congestion_surcharge  | DECIMAL(18,4) | Congestion surcharge          | CSV file | None            |
