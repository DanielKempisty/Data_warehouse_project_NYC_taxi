------------------------------------------------------
-- 1. Data source tables
------------------------------------------------------
TRUNCATE TABLE etl.data_source;
GO

INSERT INTO etl.data_source(
	path,
	destination_table,
	delimeter)
VALUES
	-- YELLOW TAXI
	('C:\yellow_tripdata_2024-01.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow_tripdata_2024-02.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow_tripdata_2024-03.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow_tripdata_2024-04.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow_tripdata_2024-05.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-06.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-07.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-08.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-09.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-10.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-11.csv', 'bronze.td_yellow_taxi', ','),
	('C:\yellow taxi\yellow_tripdata_2024-12.csv', 'bronze.td_yellow_taxi', ','),

	-- GREEN TAXI
	('C:\green taxi\green_tripdata_2024-01.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-02.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-03.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-04.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-05.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-06.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-07.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-08.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-09.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-10.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-11.csv', 'bronze.td_green_taxi', ','),
	('C:\green taxi\green_tripdata_2024-12.csv', 'bronze.td_green_taxi', ','),

	-- FOR-HIRE (FHVHV)
	('C:\fhvhv_tripdata_2024-01.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-02.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-03.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-04.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-05.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-06.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-07.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-08.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-09.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-10.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-11.csv', 'bronze.td_for_hire', ','),
	('C:\for-hire\fhvhv_tripdata_2024-12.csv', 'bronze.td_for_hire', ','),

	('C:\taxi zones.csv', 'bronze.td_taxi_zones', ','),
	('C:\license number.csv', 'bronze.td_license', ','),
	('C:\weather_2024.csv', 'bronze.wd_weather', ','),
	('C:\NYC_Permitted_Event.csv', 'bronze.ed_events', '|'),
	('C:\holidays.csv', 'bronze.hd_holidays', ',');
GO

------------------------------------------------------
-- 2. Indexes table
------------------------------------------------------
TRUNCATE TABLE etl.indexes;
GO

INSERT INTO etl.indexes
    (index_schema, index_table, index_column, index_type, index_name, reference_table, reference_column)
VALUES
    ('silver', 'borough', 'borough_id', 'PK', 'PK_borough_borough_id', NULL, NULL),
    ('silver', 'ed_event_agency', 'agency_id', 'PK', 'PK_ed_event_agency_agency_id', NULL, NULL),
    ('silver', 'ed_event_type', 'event_type_id', 'PK', 'PK_ed_event_type_event_type_id', NULL, NULL),
    ('silver', 'ed_events', 'event_occurance_id', 'PK', 'PK_ed_events_event_occurance_id', NULL, NULL),
    ('silver', 'ed_street_closure_type', 'street_closure_type_id', 'PK', 'PK_ed_street_closure_type_street_closure_type_id', NULL, NULL),
    ('silver', 'hd_date', 'date_key', 'PK', 'PK_hd_date_date_key', NULL, NULL),
    ('silver', 'qc_conditions', 'error_id', 'PK', 'PK_qc_conditions_error_id', NULL, NULL),
    ('silver', 'td_for_hire', 'trip_id', 'PK', 'PK_td_for_hire_trip_id', NULL, NULL),
    ('silver', 'td_green_taxi', 'trip_id', 'PK', 'PK_td_green_taxi_trip_id', NULL, NULL),
    ('silver', 'td_license', 'hvfhs_license_num', 'PK', 'PK_td_license_hvfhs_license_num', NULL, NULL),
    ('silver', 'td_payment_type', 'payment_type_id', 'PK', 'PK_td_payment_type_payment_type_id', NULL, NULL),
    ('silver', 'td_reject', 'reject_id', 'PK', 'PK_td_reject_reject_id', NULL, NULL),
    ('silver', 'td_tariff_type', 'tariff_type_id', 'PK', 'PK_td_tariff_type_tariff_type_id', NULL, NULL),
    ('silver', 'td_taxi_zones', 'location_id', 'PK', 'PK_td_taxi_zones_location_id', NULL, NULL),
    ('silver', 'td_trip_type', 'trip_type_id', 'PK', 'PK_td_trip_type_trip_type_id', NULL, NULL),
    ('silver', 'td_vendor', 'vendor_id', 'PK', 'PK_td_vendor_vendor_id', NULL, NULL),
    ('silver', 'td_yellow_taxi', 'trip_id', 'PK', 'PK_td_yellow_taxi_trip_id', NULL, NULL),

    ('silver', 'ed_events', 'agency_id', 'FK', 'FK_ed_events_agency_id', 'ed_event_agency', 'agency_id'),
    ('silver', 'ed_events', 'start_date_key', 'FK', 'FK_ed_events_start_date_key', 'hd_date', 'date_key'),
    ('silver', 'ed_events', 'end_date_key', 'FK', 'FK_ed_events_end_date_key', 'hd_date', 'date_key'),
    ('silver', 'ed_events', 'event_type_id', 'FK', 'FK_ed_events_event_type_id', 'ed_event_type', 'event_type_id'),
    ('silver', 'ed_events', 'borough_id', 'FK', 'FK_ed_events_borough_id', 'borough', 'borough_id'),
    ('silver', 'ed_events', 'street_closure_type_id', 'FK', 'FK_ed_events_street_closure_type_id', 'ed_street_closure_type', 'street_closure_type_id'),
    ('silver', 'ed_events', 'reject_id', 'FK', 'FK_ed_events_reject_id', 'td_reject', 'reject_id'),

    ('silver', 'td_for_hire', 'hvfhs_license_num', 'FK', 'FK_td_for_hire_hvfhs_license_num', 'td_license', 'hvfhs_license_num'),
    ('silver', 'td_for_hire', 'pu_date_key', 'FK', 'FK_td_for_hire_pu_date_key', 'hd_date', 'date_key'),
    ('silver', 'td_for_hire', 'do_date_key', 'FK', 'FK_td_for_hire_do_date_key', 'hd_date', 'date_key'),
    ('silver', 'td_for_hire', 'pu_location_id', 'FK', 'FK_td_for_hire_pu_location_id', 'td_taxi_zones', 'location_id'),
    ('silver', 'td_for_hire', 'do_location_id', 'FK', 'FK_td_for_hire_do_location_id', 'td_taxi_zones', 'location_id'),
    ('silver', 'td_for_hire', 'reject_id', 'FK', 'FK_td_for_hire_reject_id', 'td_reject', 'reject_id'),

    ('silver', 'td_green_taxi', 'vendor_id', 'FK', 'FK_td_green_taxi_vendor_id', 'td_vendor', 'vendor_id'),
    ('silver', 'td_green_taxi', 'pu_date_key', 'FK', 'FK_td_green_taxi_pu_date_key', 'hd_date', 'date_key'),
    ('silver', 'td_green_taxi', 'do_date_key', 'FK', 'FK_td_green_taxi_do_date_key', 'hd_date', 'date_key'),
    ('silver', 'td_green_taxi', 'pu_location_id', 'FK', 'FK_td_green_taxi_pu_location_id', 'td_taxi_zones', 'location_id'),
    ('silver', 'td_green_taxi', 'do_location_id', 'FK', 'FK_td_green_taxi_do_location_id', 'td_taxi_zones', 'location_id'),
    ('silver', 'td_green_taxi', 'trip_type_id', 'FK', 'FK_td_green_taxi_trip_type_id', 'td_trip_type', 'trip_type_id'),
    ('silver', 'td_green_taxi', 'tariff_type_id', 'FK', 'FK_td_green_taxi_tariff_type_id', 'td_tariff_type', 'tariff_type_id'),
    ('silver', 'td_green_taxi', 'payment_type_id', 'FK', 'FK_td_green_taxi_payment_type_id', 'td_payment_type', 'payment_type_id'),
    ('silver', 'td_green_taxi', 'reject_id', 'FK', 'FK_td_green_taxi_reject_id', 'td_reject', 'reject_id'),

    ('silver', 'td_taxi_zones', 'borough_id', 'FK', 'FK_td_taxi_zones_borough_id', 'borough', 'borough_id'),

    ('silver', 'td_yellow_taxi', 'vendor_id', 'FK', 'FK_td_yellow_taxi_vendor_id', 'td_vendor', 'vendor_id'),
    ('silver', 'td_yellow_taxi', 'pu_date_key', 'FK', 'FK_td_yellow_taxi_pu_date_key', 'hd_date', 'date_key'),
    ('silver', 'td_yellow_taxi', 'do_date_key', 'FK', 'FK_td_yellow_taxi_do_date_key', 'hd_date', 'date_key'),
    ('silver', 'td_yellow_taxi', 'pu_location_id', 'FK', 'FK_td_yellow_taxi_pu_location_id', 'td_taxi_zones', 'location_id'),
    ('silver', 'td_yellow_taxi', 'do_location_id', 'FK', 'FK_td_yellow_taxi_do_location_id', 'td_taxi_zones', 'location_id'),
    ('silver', 'td_yellow_taxi', 'tariff_type_id', 'FK', 'FK_td_yellow_taxi_tariff_type_id', 'td_tariff_type', 'tariff_type_id'),
    ('silver', 'td_yellow_taxi', 'payment_type_id', 'FK', 'FK_td_yellow_taxi_payment_type_id', 'td_payment_type', 'payment_type_id'),
    ('silver', 'td_yellow_taxi', 'reject_id', 'FK', 'FK_td_yellow_taxi_reject_id', 'td_reject', 'reject_id'),

    ('silver', 'wd_weather', 'weather_date_key', 'FK', 'FK_wd_weather_weather_date_key', 'hd_date', 'date_key'),

    ('gold', 'fact_trips', NULL, 'CCI', 'CCI_fact_trips', NULL, NULL),
    ('gold', 'fact_weather', NULL, 'CCI', 'CCI_fact_weather', NULL, NULL),
    ('gold', 'fact_events', NULL, 'CCI', 'CCI_fact_events', NULL, NULL),
    ('gold', 'dim_borough', 'borough_id', 'PK', 'PK_dim_borough_borough_id', NULL, NULL),
    ('gold', 'dim_date', 'date_key', 'PK', 'PK_dim_date_date_key', NULL, NULL),
    ('gold', 'dim_event_agency', 'agency_id', 'PK', 'PK_dim_event_agency_agency_id', NULL, NULL),
    ('gold', 'dim_event_type', 'event_type_id', 'PK', 'PK_dim_event_type_event_type_id', NULL, NULL),
    ('gold', 'dim_street_closure_type', 'street_closure_type_id', 'PK', 'PK_dim_street_closure_type_street_closure_type_id', NULL, NULL),
    ('gold', 'dim_taxi_type', 'taxi_type_id', 'PK', 'PK_dim_taxi_type_taxi_type_id', NULL, NULL),
    ('gold', 'fact_events', 'event_date_key', 'FK', 'FK_fact_events_event_date_key', 'dim_date', 'date_key'),
    ('gold', 'fact_events', 'agency_id', 'FK', 'FK_fact_events_agency_id', 'dim_event_agency', 'agency_id'),
    ('gold', 'fact_events', 'event_type_id', 'FK', 'FK_fact_events_event_type_id', 'dim_event_type', 'event_type_id'),
    ('gold', 'fact_events', 'borough_id', 'FK', 'FK_fact_events_borough_id', 'dim_borough', 'borough_id'),
    ('gold', 'fact_events', 'street_closure_type_id', 'FK', 'FK_fact_events_street_closure_type_id', 'dim_street_closure_type', 'street_closure_type_id'),
    ('gold', 'fact_trips', 'taxi_type_id', 'FK', 'FK_fact_trips_taxi_type_id', 'dim_taxi_type', 'taxi_type_id'),
    ('gold', 'fact_trips', 'pu_date_key', 'FK', 'FK_fact_trips_pu_date_key', 'dim_date', 'date_key'),
    ('gold', 'fact_trips', 'do_date_key', 'FK', 'FK_fact_trips_do_date_key', 'dim_date', 'date_key'),
    ('gold', 'fact_trips', 'pu_borough_id', 'FK', 'FK_fact_trips_pu_borough_id', 'dim_borough', 'borough_id'),
    ('gold', 'fact_trips', 'do_borough_id', 'FK', 'FK_fact_trips_do_borough_id', 'dim_borough', 'borough_id'),
    ('gold', 'fact_weather', 'weather_date_key', 'FK', 'FK_fact_weather_weather_date_key', 'dim_date', 'date_key');


