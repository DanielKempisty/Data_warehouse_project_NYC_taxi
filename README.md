## 🚕 Project Overview

This project is an end-to-end **data warehouse focused primarily on New York City taxi trip data**, designed to simulate a real-world data engineering solution. The main goal was to practice and deepen understanding of **data engineering concepts**, including ETL processes, SQL-based transformations (procedures, functions, indexing), and layered data architecture.

The core dataset consists of **NYC taxi trips** (Yellow, Green, and For-Hire Vehicles), which is enriched with **weather data from Central Park** and **city events and holidays**. These additional sources allow for more advanced analytical use cases, such as analyzing the impact of weather conditions and events on taxi demand and pricing.

Data is ingested in **batch mode** and processed using a **three-layer medallion architecture (Bronze, Silver, Gold)**, resulting in analytics-ready datasets optimized for reporting and exploration.

### 🏗️ High-Level Architecture

![Data Warehouse Architecture](docs/Architecture_diagram.png)

The architecture was designed to be **flexible and extensible**. Although the project currently covers historical data for the year **2024 only**, adding data for future years (e.g. 2025) would require minimal changes to the existing pipeline.

The final output of the project includes:
- a curated **data warehouse (Gold layer)** designed for analytical use cases,
- a **Power BI dashboard** primarily targeting data analysts, with the possibility of supporting business-oriented reporting through additional aggregations.

While this project is a learning-focused simulation, it was built to resemble a **production-like environment**, incorporating elements such as logging, SQL procedures, and basic data quality checks.

## 🔍 Problem Statement & Use Cases

### 🧩 Problem Statement

Analyzing NYC taxi trips requires working with **large, raw, and fragmented datasets** that are difficult to use directly for analytical purposes. While detailed trip-level data is publicly available, it is not provided as a **single, clean, and analytics-ready data source**, nor is it easily extendable with additional contextual data.

From a **data analyst’s perspective**, there is a need for a curated dataset that:
- consolidates taxi trip data into a consistent schema,
- can be enriched with external data sources such as weather and city events,
- supports time-based, location-based, and demand-driven analysis.

This project addresses that gap by building a structured data warehouse that transforms raw data into a reliable analytical foundation.

---

### 📊 Key Analytical Use Cases

The data warehouse enables analysis of NYC taxi activity across multiple dimensions, including time, location, weather conditions, and events.

#### Demand & Traffic Patterns
- When is taxi demand the highest during the day?
- How does demand differ by day of week and season?
- Which areas of New York City generate the most trips?

#### Pricing & Trip Characteristics
- What factors influence trip prices?
- How do average fare amounts and trip distances change over time?
- Are there observable pricing patterns during high-demand periods?

#### Weather Impact
- How do weather conditions (temperature, precipitation) affect taxi demand?
- Does bad weather correlate with higher trip volumes or prices?

#### Events & Holidays
- Do city events and public holidays increase taxi traffic?
- How does demand during event days compare to regular days?

---

### 🎯 Target User

- Data analysts exploring transportation patterns and trends in New York City  
- Analysts looking for a clean, extensible dataset for ad-hoc analysis and reporting

---

### 🔎 Scope of Analysis

- Historical, batch-processed data (year 2024)
- Descriptive and exploratory analytics
- No real-time processing or predictive modeling

## 📁 Repository Structure
```  
Data_warehouse_project_NYC_taxi/
│
├── docs                            # Documentation, data models, and architecture artifacts
│ ├── bronze                        # Data catalogs for the Bronze layer (raw datasets)
│ ├── silver                        # Data catalogs for the Silver layer (cleaned and conformed data)
│ ├── gold                          # Data catalogs for the Gold layer (analytics-ready data)
│ │
│ ├── naming_conventions.md         # Naming standards for schemas, tables, and columns
│ ├── Architecture_diagram.png      # High-level data warehouse architecture diagram
│ ├── Data_model_silver.png         # Logical data model for the Silver layer
│ └── Data_model_gold.png           # Analytical data model for the Gold layer
│
├── scripts                         # SQL scripts for data ingestion and transformations
│ ├── bronze                        # Scripts for extracting and loading raw source data
│ ├── silver                        # Scripts for cleaning, standardizing, and integrating data
│ └── gold                          # Scripts for aggregations and analytical tables
│
└── README.md                       # Project overview, architecture, and documentation
```  
## 🟫 Bronze Layer – Raw Data

### 📥 Data Scope

The Bronze layer stores raw data ingested from multiple external public sources:

- **NYC Taxi Trips**
  - Yellow Taxi
  - Green Taxi
  - For-Hire Vehicles (FHV)
- **Weather Data**
  - Daily weather observations from Central Park
- **City Events**
  - Public events in New York City
- **Holidays**
  - Official public holidays for the year 2024

Taxi trip data represents the **core dataset** of the warehouse, while weather, events, and holidays serve as contextual enrichment sources.

---

### ⚙️ Data Ingestion Process

Source data is originally provided in **Parquet format** (taxi trips) and other structured formats (weather, events, holidays).  
Before loading into the data warehouse:

1. Source files are converted to **CSV format using Python**.
2. Data is loaded into the database using **SQL Server (SSMS)** via `BULK INSERT` statements.
3. Dedicated SQL scripts handle the ingestion process for each dataset.

All data is ingested in **batch mode**.

---

### 🗂️ Data Organization

- Source systems provide **one file per month** for taxi trip data.
- In the Bronze layer, data is consolidated into **one table per dataset containing the full year (2024)**.
- Tables reflect the original source structure as closely as possible.

No data from different sources is joined or integrated at this stage.

---

### 🔒 Transformations & Constraints

- No business or analytical transformations are applied.
- No data cleansing, deduplication, or filtering is performed.
- Data is stored **as-is**, preserving the original source values.

The Bronze layer acts as a **raw and immutable landing zone**.

---

### 📊 Logging & Observability

The ingestion process includes logging mechanisms capturing:
- source dataset name,
- load timestamp,
- number of records loaded,
- load status.

This provides basic observability and traceability for all ingestion operations.

---

### ⚖️ Design Trade-offs

- ✔️ Preserves full data lineage and auditability  
- ✔️ Simplifies reprocessing and debugging  
- ❌ Data is not analytics-ready  
- ❌ Data quality issues from source systems are intentionally not resolved at this stage

## ⬜ Silver Layer – Clean & Conformed Data

### 📥 Data Scope

The Silver layer contains **cleaned and standardized data** from the Bronze layer.  
It includes selected columns from the raw datasets:

- **Taxi Trips** (Yellow, Green, For-Hire Vehicles) – core dataset for analytics  
- **Weather Data** – daily observations from Central Park  
- **City Events & Holidays** – contextual enrichment for trips  

This layer consolidates multiple sources while removing irrelevant or problematic columns, ensuring that the data is consistent and reliable for downstream analytical processes.

---

### ⚙️ Transformations & Integration

Key transformations performed in Silver:

1. **Data cleaning & normalization**  
   - Standardization of column types (e.g., dates, numeric types)  
   - Deduplication of records  
   - Removal of nulls and obviously erroneous values  
   - Unit conversions (e.g., miles → kilometers)  

2. **Integration of sources**  
   - Events joined to trips by `date` and `borough`  
   - Weather and holidays joined by `date`  

3. **Quality checks**  
   - Each table is validated using predefined conditions  
   - Rejected records are tagged with `reject_id`  
   - A dedicated table describes the meaning of each `reject_id`  

Sample checks include:

| table_name | condition | error_id | error_message |
|------------|-----------|----------|---------------|
| td_yellow_taxi | pu_datetime >= do_datetime | 101 | VALUES WITH pu_datetime >= do_datetime |
| td_yellow_taxi | passenger_cnt > 9 | 102 | VALUES > 9 IN COLUMN passenger_cnt |
| td_yellow_taxi | total_amount <> (tip_amount + extra + mta_tax + airport_fee + congestion_surcharge + improvement_surcharge + tolls_amount + fare_amount) | 103 | COLUMN total_amount not equal to its components |
| ... | ... | ... | ... |

> ⚠️ Full quality check table includes all taxi types and event tables.

---

### 🗂️ Data Modeling

- The Silver layer uses **fact and dimension tables** to organize cleaned data  
- Prepares data for analytics without performing business-level aggregations  
- Diagram of Silver layer data model:  

![Silver Layer Data Model](docs/Data_model_silver.png)  

---

### 🔒 Transformations NOT Applied

- No aggregations or business metrics are calculated yet  
- Per-trip granularity is preserved  
- Advanced business logic is deferred to Gold layer  

---

### ⚖️ Design Trade-offs

- ✔️ Provides a **clean and standardized foundation** for analytics  
- ✔️ Integrates multiple contextual sources (weather, events, holidays)  
- ✔️ Preserves original trip-level granularity  
- ❌ Does not include business metrics or aggregations (deferred to Gold)  
- ❌ Some complex corrections (beyond obvious errors) are not applied to keep raw signal intact  



