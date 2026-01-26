| Column Name          | Data Type     | Description                                                                       | Source    | Transformation |
| -------------------- | ------------- | --------------------------------------------------------------------------------- | --------- | -------------- |
| hvfhs_license_num    | NVARCHAR(20)  | Unique license number of the for-hire vehicle assigned to the trip.               | CSV files | None           |
| dispatch_base_num    | NVARCHAR(20)  | Identifier for the base that dispatched the vehicle, if applicable.               | CSV files | None           |
| originate_base_num   | NVARCHAR(20)  | Original base number where the trip originated.                                   | CSV files | None           |
| request_datetime     | DATETIME2     | Date and time when the passenger requested the trip.                              | CSV files | None           |
| on_scene_datetime    | DATETIME2     | Date and time when the vehicle arrived at the pickup location.                    | CSV files | None           |
| pu_datetime          | DATETIME2     | Pickup date and time of the trip when the passenger boarded.                      | CSV files | None           |
| do_datetime          | DATETIME2     | Dropoff date and time of the trip when the passenger exited.                      | CSV files | None           |
| pu_location_id       | INT           | ID of the pickup location zone.                                                   | CSV files | None           |
| do_location_id       | INT           | ID of the dropoff location zone.                                                  | CSV files | None           |
| trip_distance        | DECIMAL(18,4) | Trip distance in miles as recorded by the meter or system.                        | CSV files | None           |
| trip_time            | INT           | Total trip duration in minutes from pickup to dropoff.                            | CSV files | None           |
| base_passenger_fee   | DECIMAL(18,4) | Base fare for the trip charged to the passenger.                                  | CSV files | None           |
| tolls_amount         | DECIMAL(18,4) | Toll fees incurred during the trip.                                               | CSV files | None           |
| bcf_fee              | DECIMAL(18,4) | Broker or central fee applied by the dispatch base.                               | CSV files | None           |
| sales_tax            | DECIMAL(18,4) | Tax portion applied to the trip fare.                                             | CSV files | None           |
| congestion_surcharge | DECIMAL(18,4) | Fee applied for trips during congestion pricing periods.                          | CSV files | None           |
| airport_fee          | DECIMAL(18,4) | Fee applied for trips starting or ending at airports.                             | CSV files | None           |
| tip_amount           | DECIMAL(18,4) | Tip paid to the driver.                                                           | CSV files | None           |
| driver_pay           | DECIMAL(18,4) | Amount paid to the driver after fees and commissions.                             | CSV files | None           |
| total_amount         | DECIMAL(18,4) | Total charge to the passenger including all fees, surcharges, and tips.           | CSV files | None           |
| shared_request       | NVARCHAR(20)  | Indicator if the trip was requested as a shared ride.                             | CSV files | None           |
| shared_match         | NVARCHAR(20)  | Indicator if the trip was successfully matched with other shared ride passengers. | CSV files | None           |
| access_a_ride        | NVARCHAR(20)  | Indicator for accessibility request (e.g., wheelchair access).                    | CSV files | None           |
| wav_request          | NVARCHAR(20)  | Indicator if wheelchair accessible vehicle was requested.                         | CSV files | None           |
| wav_match            | NVARCHAR(20)  | Indicator if a wheelchair accessible vehicle was assigned.                        | CSV files | None           |
