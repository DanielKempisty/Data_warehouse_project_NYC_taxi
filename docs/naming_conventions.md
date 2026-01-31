# **Naming Conventions**

This document outlines the naming conventions for objects in the data warehouse.

## **General Principles**

- **Naming Conventions**: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- **Language**: Use English for all names.

## **Table Naming Conventions**

### **Bronze Rules**
- All names must start with the source abbreviation.
- **`<sourcesystem>_<entity>`**  
  - `<sourcesystem>`: Name of the source system:
    - td - taxi data
    - wd - weather data
    - ed - events data
    - hd - holidays data
  - `<entity>`: Name of the table.  
  - Example: `td_yellow_taxi` 

### **Silver Rules**
- Same as bronze rules

### **Gold Rules**
- All names must use meaningful, business-aligned names for tables, starting with the category prefix.
- **`<category>_<entity>`**  
  - `<category>`: Describes the role of the table, such as `dim` (dimension) or `fact` (fact table).  
  - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g., `trips`, `events`, `taxi_type`).  
  - Examples:
    - `dim_taxi_type` → Dimension table for taxi type info.  
    - `fact_trips` → Fact table containing trips.  
 
## **Stored Procedure**

- All stored procedures used for loading data must follow the naming pattern:
- **`load_<entity>_to_<layer>`**.
  - `<entity>`: Name of the table or tables to load
  - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.
  - Example: 
    - `load_events_to_gold` → Stored procedure for loading events data into the Gold layer.

