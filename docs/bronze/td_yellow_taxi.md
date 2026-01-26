| Column Name           | Data Type     | Description                                                                                            | Source    | Transformation |
| --------------------- | ------------- | ------------------------------------------------------------------------------------------------------ | --------- | -------------- |
| vendor_id             | INT           | Identifier of the taxi vendor/company that provided the ride. Typically 1 or 2 for NYC yellow taxis.   | CSV files | None           |
| pu_datetime           | DATETIME2     | Pickup date and time of the trip. Captures when the passenger was picked up.                           | CSV files | None           |
| do_datetime           | DATETIME2     | Dropoff date and time of the trip. Captures when the passenger reached the destination.                | CSV files | None           |
| passenger_cnt         | DECIMAL(18,4) | Number of passengers in the trip. Can include fractional values due to data inconsistencies.           | CSV files | None           |
| trip_distance         | DECIMAL(18,4) | Distance of the trip in miles as reported by the meter.                                                | CSV files | None           |
| tariff_type           | DECIMAL(18,4) | Tariff type code used for fare calculation (e.g., standard, flat-rate).                                | CSV files | None           |
| store_and_fwd         | NVARCHAR(20)  | Indicator if the trip record was stored locally and forwarded later to TLC. Values usually 'Y' or 'N'. | CSV files | None           |
| pu_location_id        | INT           | Pickup location ID referencing the taxi zone where the passenger was picked up.                        | CSV files | None           |
| do_location_id        | INT           | Dropoff location ID referencing the taxi zone where the passenger was dropped off.                     | CSV files | None           |
| payment_type          | DECIMAL(18,4) | Code indicating how the passenger paid (cash, credit, no charge, etc.).                                | CSV files | None           |
| fare_amount           | DECIMAL(18,4) | Base fare charged for the trip excluding taxes, tips, or surcharges.                                   | CSV files | None           |
| extra                 | DECIMAL(18,4) | Miscellaneous extra charges (e.g., NYC fee, peak surcharge).                                           | CSV files | None           |
| mta_tax               | DECIMAL(18,4) | MTA tax portion of the fare applied to each trip.                                                      | CSV files | None           |
| tip_amount            | DECIMAL(18,4) | Tip given by the passenger.                                                                            | CSV files | None           |
| tolls_amount          | DECIMAL(18,4) | Toll fees incurred during the trip.                                                                    | CSV files | None           |
| improvement_surcharge | DECIMAL(18,4) | Surcharge applied by the city for taxi improvement programs.                                           | CSV files | None           |
| total_amount          | DECIMAL(18,4) | Total charged to the passenger, including fare, taxes, surcharges, tolls, and tips.                    | CSV files | None           |
| congestion_surcharge  | DECIMAL(18,4) | Additional fee applied during congestion pricing periods.                                              | CSV files | None           |
| airport_fee           | DECIMAL(18,4) | Fixed fee applied for trips to/from airports.                                                          | CSV files | None           |
