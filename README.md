# 🚕 NYC Taxi Data Warehouse

This project is an **end-to-end batch-oriented data warehouse** built on NYC taxi trip data, enriched with **weather data** and **city events**. It demonstrates a **production-like data engineering solution** with a focus on data quality, deterministic processing, and performance optimization.

The final output is a **Gold-layer warehouse** optimized for analytical consumption and a **Power BI dashboard**.

---

## 🔍 Problem & Motivation

Raw NYC taxi data is **fragmented and inconsistent**, making direct analysis difficult. Challenges include:

- Different schemas across taxi types
- Limited data quality guarantees
- No unified analytical layer
- Hard enrichment with external datasets

This project solves these by:

- Consolidating multiple sources into a unified model
- Enforcing data quality and referential integrity
- Supporting safe enrichment with weather and events
- Providing a stable, analytics-ready foundation for BI

---

## 🏗️ Architecture

The warehouse follows a **three-layer medallion architecture**:

![Data Warehouse Architecture](docs/Architecture_overview.png)

### 🥉 Bronze – Raw Data

- Stores raw datasets via **BULK INSERT** (SQL Server)
- **No transformations**; preserves lineage
- Landing zone for debugging and reprocessing

### 🥈 Silver – Cleaned & Conformed

- Data cleaning, standardization, and integration with weather/events
- Enforces **Primary/Foreign Keys** and indexes
- Tags invalid records with `reject_id` for traceability
- Preserves **per-trip granularity** for analytics

### 🥇 Gold – Aggregated & Analytics-Ready

- Aggregated datasets optimized for **Power BI dashboards**
- Uses **Clustered Columnstore Indexes** for fast analytical queries
- Batch-loaded, read-heavy layer with stable, high-performance tables

> The architecture is modular and can easily be extended to additional datasets or years.

---

## ⚙️ Design Decisions

### Layer Isolation

- Each layer is in a **separate schema** for clear responsibility and safe reprocessing.

### Indexing

| Layer  | Indexing Strategy                                                                 |
|--------|---------------------------------------------------------------------------------|
| Bronze | No indexes – optimized for high-throughput batch loads                           |
| Silver | Primary keys (clustered), non-clustered indexes on join/date keys, foreign keys |
| Gold   | Clustered Columnstore Indexes for fast analytical scans                           |

### Data Quality & Observability

- Stored procedures log dataset, timestamp, row count, and status
- Invalid records tagged with `reject_id` and mapped to documented rules
- Re-validation ensures correct assignment of rejects

### Idempotent Processing

- Silver and Gold use **`TRUNCATE + INSERT`** for deterministic results
- Enables easy reprocessing and recovery from upstream issues

---

## 🔧 Metrics & Tools

### Dataset Size & Load Times (2024)

| Layer  | Records       | Load Time (min) |
|--------|--------------|----------------|
| Bronze | 292,094,834  | 45.9           |
| Silver | 281,750,218  | 49.2           |
| Gold   | 11,433,159   | 4.3            |

### Tools

- **SQL Server** (SSMS, stored procedures, dynamic SQL)
- **Power BI** for dashboards
- Minimal Python for CSV conversion before ingestion

---

## 📊 Power BI Dashboard

- Built on **Gold layer**; supports filtering by time, location, taxi type, and trip attributes
- Interactive exploration of trips with weather and event context
- [Dashboard link (Google Drive)](https://drive.google.com/drive/folders/1HApFSHVwSZA4j4U3zWaxO_Lec31eu6VE?usp=sharing) (~250 MB)

![Dashboard Screenshot](docs/Dashboard_screen.png)

> Designed for data analysts, while Gold layer also supports business reporting.

---

## 📥 Data Sources

- **NYC Taxi Trips:** [NYC Open Data](https://www.nyc.gov/data)  
- **Weather Data:** Central Park Historical Weather [NCEI](https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/)  
- **City Events:** Public NYC events dataset [NYC Open Data](https://www.nyc.gov/data)  

---

## 📂 Repository Structure

```
Data_warehouse_project_NYC_taxi/
Data_warehouse_project_NYC_taxi/
│
├── docs/                                         # Project documentation and architecture
│   ├── bronze/                                   # Table and column descriptions for Bronze layer
│   ├── silver/                                   # Table and column descriptions for Silver layer
│   ├── gold/                                     # Table and column descriptions for Gold layer
│   ├── Architecture_overview.png                 # High-level architecture diagram
│   ├── Dashboard_screen.png                      # Power BI dashboard screenshot
│   ├── Data_model_silver.png                     # Silver layer data model diagram
│   ├── Data_model_gold.png                       # Gold layer data model diagram
│   └── naming_conventions.md                     # Naming standards for schemas, tables, and columns
│
├── scripts/                                      # SQL scripts for ETL and transformations
│   ├── bronze/                                   # Scripts for extracting & loading raw data
│   ├── silver/                                   # Scripts for cleaning, standardizing, and integrating data
│   ├── gold/                                     # Scripts for aggregations and analytical tables
│
└── README.md                                     # Project overview and documentation

```



