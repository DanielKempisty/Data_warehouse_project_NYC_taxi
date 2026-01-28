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

Data_warehouse_project_NYC_taxi/
│
├── docs/
│ ├── bronze/
│ ├── silver/
│ ├── gold/
│ │
│ ├── naming_conventions.md
│ ├── Architecture_diagram.png
│ ├── Data_model_silver.png
│ └── Data_model_gold.png
│
├── scripts/
│ ├── bronze/
│ ├── silver/
│ └── gold/
│
└── README.md

