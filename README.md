## 🚕 Project Overview

This project is an end-to-end **batch-oriented data warehouse** built on New York City taxi trip data, designed to simulate a **production-like data engineering solution**.

The core dataset consists of **NYC taxi trips** (Yellow, Green, and For-Hire Vehicles), enriched with **weather data from Central Park** and **city events and holidays**. The goal is to transform large, raw, and fragmented datasets into a **reliable, analytics-ready data foundation**.

Data is processed using a **three-layer medallion architecture (Bronze, Silver, Gold)**, with a strong focus on:
- data quality enforcement,
- deterministic and idempotent processing,
- performance optimization for analytical workloads.

The final output is a curated **Gold-layer data warehouse** optimized for analytical consumption and a downstream **Power BI dashboard** built on top of it.

---

## 🔍 Problem Statement & Why It Matters

Public NYC taxi data is available at a very granular level, but in its raw form it is **not suitable for direct analytical use**. The data is fragmented across multiple taxi types, lacks a unified schema, and does not include important contextual information such as weather conditions or city-wide events.

From a data engineering perspective, this creates several challenges:
- inconsistent schemas across sources,
- limited data quality guarantees,
- no single, trusted analytical layer,
- difficult and error-prone enrichment with external datasets.

From an analytical and business perspective, this makes it hard to answer common questions about **demand patterns, pricing behavior, and external factors influencing taxi activity** in a reliable and repeatable way.

This project addresses these challenges by building a structured data warehouse that:
- consolidates multiple raw data sources into a unified model,
- enforces data quality and referential integrity at the database level,
- enables safe enrichment with external context data,
- provides a stable, analytics-ready foundation for downstream reporting and exploration.

---

## 🏗️ High-Level Architecture

The solution follows a **batch-oriented medallion architecture** with clear separation of responsibilities across three data layers: **Bronze, Silver, and Gold**.

![Data Warehouse Architecture](docs/Architecture_overview.png)

### 🥉 Bronze Layer – Raw Data

- Stores **raw datasets** from external sources.
- Data is ingested via **BULK INSERT** in SQL Server, in batch mode.
- **No transformations** are applied; data is stored **as-is** to preserve lineage and ensure full auditability.
- Serves as a **landing zone** for reprocessing and debugging.

### 🥈 Silver Layer – Cleaned & Conformed Data

- Performs **data cleaning and standardization**
- **Integrates external sources**:
  - weather and events joined to trips by date/borough.
- Implements **Primary/Foreign Keys** and indexes to ensure referential integrity and efficient joins.
- Applies **data quality rules**, tags invalid records with `reject_id`, and validates proper assignment.
- Preserves **per-trip granularity** for downstream analytics.

### 🥇 Gold Layer – Aggregated & Analytics-Ready Data

- Produces **aggregated datasets** optimized for reporting and dashboards:
- Uses **Clustered Columnstore Indexes** for high-performance analytical queries.
- Designed to support **Power BI dashboards** and other analytical tools without modifying raw or Silver data.

The architecture is designed to be **modular and extensible**. Although the current implementation processes historical data for the year 2024, extending the pipeline to support additional years or datasets would require minimal structural changes.

---

## ⚙️ Data Engineering Design Decisions

This project was designed with a **data engineering–first mindset**, prioritizing **data integrity, operational safety, and performance optimization**.

### Schemas & Layer Isolation

- Each layer (**Bronze, Silver, Gold**) is stored in a **separate schema**.
- This ensures clear responsibility boundaries and prevents accidental cross-layer dependencies.
- Enables safe reprocessing and maintenance without affecting downstream layers.

### Indexing Strategy by Layer

#### 🥉 Bronze Layer
- No indexes or constraints are defined.
- **Rationale:** Bronze is a raw ingestion layer optimized for **high-throughput batch loads**. Indexes would slow down bulk inserts without providing analytic value.

#### 🥈 Silver Layer
- **Primary Keys** implemented as **clustered indexes** to enforce uniqueness.
- **Non-clustered indexes** on date columns and join keys (locations, taxi type, event identifiers).
- **Foreign Keys** enforce referential integrity.
- **Purpose:** optimize joins, support data validation, and prevent silent duplication during transformations.

#### 🥇 Gold Layer
- Fact tables use **Clustered Columnstore Indexes**.
- **Purpose:** accelerate large-scale analytical scans, improve aggregation performance for BI tools, and reduce storage footprint.
- Write performance trade-offs are acceptable because Gold is **batch-loaded and read-heavy**.

### Logging, Data Quality & Observability

- All loads use **stored procedures** with logging:
  - dataset name, load timestamp, inserted records, execution status.
- Invalid records are tagged using **`reject_id`** (not dropped).
- Each `reject_id` maps to a documented quality rule.
- During Silver loading:
  - quality rules are applied,
  - results are re-validated to confirm correct `reject_id` assignment,
  - additional checks ensure no new unexpected errors are introduced.

This ensures **traceability, auditability, and safe debugging/reprocessing**.

### Idempotent Processing & Reprocessing

- Silver and Gold layers are **fully reprocessable**.
- Loads use **`TRUNCATE + INSERT`**, guaranteeing deterministic results.
- This ensures:
  - consistent outcomes across re-runs,
  - simplified recovery from upstream data issues.

---

## 🔧 Technical Metrics & Tools

This section provides **operational metrics** and tools used in the project, illustrating the scale and performance of the data warehouse.

### Dataset Size & Load Times

| Layer  | Records       | Full Layer Load Time (min) |
|--------|--------------|----------------------------|
| Bronze | 292,094,834  | 45.9                       |
| Silver | 281,750,218  | 49.2                       |
| Gold   | 11,433,159   | 4.3                        |

> Load times are measured for **full 2024 dataset**, batch mode, on the development environment.

### Tools & Stack

- **Database / ETL:** SQL Server (SSMS) using **stored procedures**, **dynamic SQL**, primary/foreign keys, and indexing strategies.  
- **Dashboard / Visualization:** Power BI (built on Gold layer).  
- **Additional scripting:** minimal Python for CSV conversion before ingestion.

These metrics demonstrate the **scale, performance, and operational considerations** of the pipeline, providing context for the engineering decisions described in earlier sections.

---

## 📊 Power BI Dashboard 

A **Power BI dashboard** was built on top of the Gold layer to provide analysts with **interactive exploration** of NYC taxi trips in relation to weather and city events.

![Dashboard Screenshot](docs/Dashboard_screen.png)

- The dashboard consumes **aggregated, analytics-ready datasets** from Gold.
- Supports filtering by **time, location, taxi type, and trip attributes**.
- Designed for **data analysts**, but the Gold layer structure allows adaptation for **business reporting**.
- Due to file size (~250 MB), the full dashboard is available via [Google Drive link](https://your-link-here).

---

## 📈 Example Analytical Insights

The warehouse enables analysts to generate insights such as:

- **Taxi demand peaks** during weekday evenings, especially in Manhattan.
- **Adverse weather** correlates with higher fares and shorter trips.
- **Major city events** increase trip volumes in affected boroughs.
- **Average trip speeds** drop during rush hours and large-scale events.





