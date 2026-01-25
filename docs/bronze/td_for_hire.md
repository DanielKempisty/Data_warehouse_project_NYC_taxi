| Column Name          | Data Type     | Description                           | Source   | Transformations |
| -------------------- | ------------- | ------------------------------------- | -------- | --------------- |
| hvfhs_license_num    | NVARCHAR(20)  | FHV high-volume license number        | CSV file | None            |
| dispatch_base_num    | NVARCHAR(20)  | Dispatching base number               | CSV file | None            |
| originate_base_num   | NVARCHAR(20)  | Originating base number               | CSV file | None            |
| request_datetime     | DATETIME2     | Trip request timestamp                | CSV file | None            |
| on_scene_datetime    | DATETIME2     | Vehicle arrival timestamp             | CSV file | None            |
| pu_datetime          | DATETIME2     | Pickup date and time                  | CSV file | None            |
| do_datetime          | DATETIME2     | Drop-off date and time                | CSV file | None            |
| pu_location_id       | INT           | Pickup taxi zone identifier           | CSV file | None            |
| do_location_id       | INT           | Drop-off taxi zone identifier         | CSV file | None            |
| trip_distance        | DECIMAL(18,4) | Trip distance in miles                | CSV file | None            |
| trip_time            | INT           | Trip duration in seconds              | CSV file | None            |
| base_passenger_fee   | DECIMAL(18,4) | Base passenger fare                   | CSV file | None            |
| tolls_amount         | DECIMAL(18,4) | Toll charges                          | CSV file | None            |
| bcf_fee              | DECIMAL(18,4) | Black car fund fee                    | CSV file | None            |
| sales_tax            | DECIMAL(18,4) | Applied sales tax                     | CSV file | None            |
| congestion_surcharge | DECIMAL(18,4) | Congestion surcharge                  | CSV file | None            |
| airport_fee          | DECIMAL(18,4) | Airport-related fee                   | CSV file | None            |
| tip_amount           | DECIMAL(18,4) | Tip amount                            | CSV file | None            |
| driver_pay           | DECIMAL(18,4) | Driver payout amount                  | CSV file | None            |
| shared_request       | NVARCHAR(20)  | Indicates shared ride request         | CSV file | None            |
| shared_match         | NVARCHAR(20)  | Indicates shared ride match           | CSV file | None            |
| access_a_ride        | NVARCHAR(20)  | Accessibility service indicator       | CSV file | None            |
| wav_request          | NVARCHAR(20)  | Wheelchair-accessible vehicle request | CSV file | None            |
| wav_match            | NVARCHAR(20)  | Wheelchair-accessible vehicle match   | CSV file | None            |
