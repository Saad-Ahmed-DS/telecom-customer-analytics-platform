Below is a complete `dataset_inventory.md` for your **Telecom Customer Analytics Platform**. It is written in a professional style suitable for GitHub and VS Code.

# Dataset Inventory

**Project:** Telecom Customer Analytics Platform
**Version:** 1.0
**Author:** Saad Ahmed
**Created:** June 2026

---

# Overview

This document serves as the **Data Inventory** for the Telecom Customer Analytics Platform. It provides comprehensive documentation for every dataset used in the project, including its source, structure, purpose, quality assessment, and how it will be integrated into the enterprise data warehouse.

The inventory acts as the primary metadata catalog for the ETL pipeline and dimensional data model.

---

# Dataset Summary

| Dataset                             | Source     |          Rows | Columns | Primary Key          | Target Table           |
| ----------------------------------- | ---------- | ------------: | ------: | -------------------- | ---------------------- |
| IBM Telco Customer Churn            | Kaggle     |         7,043 |      21 | customerID           | dim_customer           |
| IBM Telco Customer Churn (Extended) | Kaggle     |         7,043 |      33 | customerID           | fact_usage (Generated) |
| Pakistan Cities                     | Kaggle     |          ~600 |  Varies | city_id (Generated)  | dim_city               |
| Date Dimension                      | Generated  |        ~4,748 |     12+ | date_key             | dim_date               |
| OpenCelliD (Pakistan Sample)        | OpenCelliD | 10,000–20,000 |  Varies | tower_id (Generated) | dim_tower              |

---

# Dataset 1 — IBM Telco Customer Churn

## Basic Information

| Property               | Value                                     |
| ---------------------- | ----------------------------------------- |
| Dataset Name           | IBM Telco Customer Churn                  |
| Source                 | Kaggle                                    |
| File Name              | WA_Fn-UseC_-Telco-Customer-Churn.csv      |
| File Format            | CSV                                       |
| Rows                   | 7,043                                     |
| Columns                | 21                                        |
| Primary Key            | customerID                                |
| Candidate Foreign Keys | city_id (Generated), date_key (Generated) |
| Target Warehouse Table | dim_customer                              |

---

## Main Attributes

* Customer ID
* Gender
* Senior Citizen
* Partner
* Dependents
* Phone Service
* Multiple Lines
* Internet Service
* Online Security
* Online Backup
* Device Protection
* Tech Support
* Streaming TV
* Streaming Movies
* Contract
* Paperless Billing
* Payment Method
* Monthly Charges
* Total Charges
* Tenure
* Churn

---

## Data Types

| Type                | Examples                     |
| ------------------- | ---------------------------- |
| String              | customerID, Contract         |
| Integer             | SeniorCitizen, Tenure        |
| Decimal             | MonthlyCharges, TotalCharges |
| Boolean/Categorical | Partner, Churn               |

---

## Missing Values

Known issue:

* **TotalCharges** contains blank values for newly joined customers.

Handling Strategy:

* Convert blanks to NULL
* Replace with 0 or calculate based on business rules during ETL

---

## Business Purpose

This dataset represents the **Customer Master Data**.

It stores customer demographics, subscription details, billing information, and churn status. It becomes the central customer dimension for all analytics.

---

## Data Warehouse Mapping

```text
Source
      │
      ▼
dim_customer
```

---

# Dataset 2 — IBM Telco Customer Churn (Extended)

## Basic Information

| Property               | Value                               |
| ---------------------- | ----------------------------------- |
| Dataset Name           | IBM Telco Customer Churn (Extended) |
| Source                 | Kaggle                              |
| File Format            | CSV                                 |
| Rows                   | 7,043                               |
| Columns                | 33                                  |
| Primary Key            | customerID                          |
| Target Warehouse Table | fact_usage (Generated)              |

---

## Purpose

This dataset provides enriched customer information including:

* Geographic Information
* Customer Lifetime Value (CLTV)
* Churn Score
* Churn Category
* Latitude
* Longitude
* Customer Status

Although it is customer-level data rather than transactional usage data, it will be used to generate a realistic monthly usage fact table during the ETL process.

---

## Generated Fact Table

The ETL pipeline will create:

```text
fact_usage
```

with fields such as:

* usage_id
* customer_id
* date_key
* city_id
* tower_id
* voice_minutes
* sms_count
* data_usage_gb
* roaming_usage_mb
* international_call_minutes
* recharge_amount
* monthly_bill

Expected Size:

Approximately **300,000–1,000,000 records**.

---

## Business Purpose

Supports:

* Monthly customer activity
* Usage trends
* Revenue analytics
* Customer behavior analysis
* Churn prediction

---

# Dataset 3 — Pakistan Cities

## Basic Information

| Property               | Value               |
| ---------------------- | ------------------- |
| Dataset Name           | Pakistan Cities     |
| Source                 | Kaggle              |
| File Format            | CSV                 |
| Rows                   | ~600                |
| Columns                | Varies              |
| Primary Key            | city_id (Generated) |
| Target Warehouse Table | dim_city            |

---

## Attributes

Typical fields include:

* City
* Province
* Latitude
* Longitude
* Population

---

## ETL Transformations

* Remove duplicate cities
* Standardize province names
* Generate surrogate key
* Clean spelling inconsistencies

---

## Business Purpose

Provides the geographic dimension for:

* Customer locations
* Regional revenue
* Provincial churn analysis
* Population-based analytics

---

## Data Warehouse Mapping

```text
Cities Dataset
        │
        ▼
dim_city
```

---

# Dataset 4 — Date Dimension

## Source

Generated during ETL.

No external dataset is required.

---

## Basic Information

| Property     | Value          |
| ------------ | -------------- |
| Dataset Name | Date Dimension |
| Source       | Generated      |
| Rows         | ~4,748         |
| Columns      | 12+            |
| Primary Key  | date_key       |
| Target Table | dim_date       |

---

## Date Range

```text
2018-01-01

through

2030-12-31
```

---

## Attributes

* date_key
* full_date
* day
* day_name
* week
* month
* month_name
* quarter
* year
* weekend_flag
* fiscal_year (optional)
* holiday_flag (optional)

---

## Business Purpose

Supports:

* Time Intelligence
* Trend Analysis
* Monthly KPIs
* Quarterly Reports
* Year-over-Year Comparisons

---

## Data Warehouse Mapping

```text
Generated Calendar

        │

        ▼

dim_date
```

---

# Dataset 5 — OpenCelliD

## Basic Information

| Property     | Value                |
| ------------ | -------------------- |
| Dataset Name | OpenCelliD           |
| Source       | OpenCelliD           |
| File Format  | CSV                  |
| Rows         | Sample 10,000–20,000 |
| Primary Key  | tower_id (Generated) |
| Target Table | dim_tower            |

---

## Original Attributes

* Radio
* MCC
* MNC
* Area
* Cell
* Latitude
* Longitude
* Range
* Samples
* Signal Strength

---

## ETL Transformations

Keep only:

* tower_id
* latitude
* longitude
* radio_type

Remove:

* Signal strength
* Samples
* Unnecessary identifiers

---

## Business Purpose

Supports:

* Network Coverage Dashboard
* Tower Distribution
* Coverage Maps
* Network Performance Analytics

---

## Data Warehouse Mapping

```text
OpenCelliD

      │

      ▼

dim_tower
```

---

# Relationships Between Datasets

```text
                     dim_date
                        │
                        │
                        │
dim_city ─────┐         │        ┌──────── dim_tower
              │         │        │
              ▼         ▼        ▼
                 fact_usage
                      ▲
                      │
                      │
               dim_customer
```

---

# Data Quality Assessment

| Dataset           | Missing Values | Duplicate Risk | Quality   |
| ----------------- | -------------- | -------------- | --------- |
| Customer          | Low            | Low            | Excellent |
| Extended Customer | Low            | Low            | Excellent |
| Cities            | Medium         | Medium         | Good      |
| Date              | None           | None           | Excellent |
| Towers            | Low            | Medium         | Good      |

---

# ETL Readiness Checklist

| Task                        | Status |
| --------------------------- | ------ |
| Dataset Selection           | ✅      |
| Source Verification         | ✅      |
| Metadata Documentation      | ✅      |
| Primary Keys Identified     | ✅      |
| Business Purpose Defined    | ✅      |
| Warehouse Mapping Completed | ✅      |
| ETL Planning Ready          | ✅      |

---

# Next Phase

The next step is to design the enterprise **Star Schema** by defining dimension tables, fact tables, surrogate keys, relationships, and data warehouse architecture before implementing the ETL pipeline.
