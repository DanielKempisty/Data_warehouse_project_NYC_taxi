| Column Name           | Data Type     | Description                                                                                     | Source    | Transformation |
| --------------------- | ------------- | ----------------------------------------------------------------------------------------------- | --------- | -------------- |
| vendor_id             | INT           | Identifier of the taxi vendor/company operating the ride. Usually 1 or 2 for NYC green taxis.   | CSV files | None           |
| pu_datetime           | DATETIME2     | Pickup date and time of the trip. Captures when the passenger boarded.                          | CSV files | None           |
| do_datetime           | DATETIME2     | Dropoff date and time of the trip. Captures when the passenger reached the destination.         | CSV files | None           |
| store_and_fwd         | NVARCHAR(20)  | Indicator if the trip record was stored locally and forwarded later to TLC. Values: 'Y' or 'N'. | CSV files | None           |
| tariff_type           | DECIMAL(18,4) | Code representing fare tariff type applied to the trip.                                         | CSV files | None           |
| pu_location_id        | INT           | Pickup location ID referencing the taxi zone where the passenger boarded.                       | CSV files | None           |
| do_location_id        | INT           | Dropoff location ID referencing the taxi zone where the passenger exited.                       | CSV files | None           |
| passenger_cnt         | DECIMAL(18,4) | Number of passengers in the vehicle for this trip.                                              | CSV files | None           |
| trip_distance         | DECIMAL(18,4) | Distance of the trip in miles as reported by the meter.                                         | CSV files | None           |
| fare_amount           | DECIMAL(18,4) | Base fare charged for the trip excluding taxes, tips, or surcharges.                            | CSV files | None           |
| extra                 | DECIMAL(18,4) | Additional charges applied to the trip, such as NYC fees or surcharges.                         | CSV files | None           |
| mta_tax               | DECIMAL(18,4) | Portion of the fare corresponding to MTA tax.                                                   | CSV files | None           |
| tip_amount            | DECIMAL(18,4) | Tip paid by the passenger.                                                                      | CSV files | None           |
| tolls_amount          | DECIMAL(18,4) | Total toll fees incurred during the trip.                                                       | CSV files | None           |
| ehail_fee             | DECIMAL(18,4) | Fee charged for trips booked via electronic hailing apps.                                       | CSV files | None           |
| improvement_surcharge | DECIMAL(18,4) | City-mandated surcharge for taxi improvements.                                                  | CSV files | None           |
| total_amount          | DECIMAL(18,4) | Total charge to passenger, including fare, taxes, tips, and surcharges.                         | CSV files | None           |
| payment_type          | DECIMAL(18,4) | Code indicating payment method (cash, credit, no charge, etc.).                                 | CSV files | None           |
| trip_type             | DECIMAL(18,4) | Code indicating trip type (e.g., street hail, dispatch).                                        | CSV files | None           |
| congestion_surcharge  | DECIMAL(18,4) | Additional fee applied for trips during congestion pricing periods.                             | CSV files | None           |
