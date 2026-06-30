# 📡 Telecom Customer Analytics & Churn Intelligence Platform

An enterprise-grade, end-to-end data analytics platform built to demonstrate production-level skills in **Data Engineering**, **Data Warehousing**, **SQL Analytics**, **Business Intelligence**, and **Machine Learning** using a real telecom customer base as the business domain.

![Status](https://img.shields.io/badge/status-complete-brightgreen)
![PostgreSQL](https://img.shields.io/badge/database-PostgreSQL%2017-blue)
![Python](https://img.shields.io/badge/python-3.11-yellow)
![Power BI](https://img.shields.io/badge/BI-Power%20BI-yellow)
![Machine Learning](https://img.shields.io/badge/ML-XGBoost%20%7C%20Random%20Forest-orange)

---

# 📌 Project Overview

This project simulates a complete **Telecom Customer Analytics Platform**, beginning with raw operational datasets and ending with executive dashboards and a machine learning churn prediction model.

Unlike a simple analytics project, this repository follows an enterprise-inspired architecture using:

- Bronze → Silver → Gold Medallion Architecture
- PostgreSQL Enterprise Data Warehouse
- Star Schema Data Modeling
- Python ETL Pipelines
- SQL Analytics Layer
- Power BI Executive Dashboards
- Machine Learning Churn Prediction

The objective is to replicate how a modern telecom company transforms raw operational data into actionable business insights for executives, managers, analysts, and data scientists.

---

# 🎯 Business Problem

Telecommunication companies lose millions every year because of customer churn.

The business requires answers to questions such as:

- Which customers are most likely to churn?
- Which subscription plans generate the highest revenue?
- Which geographic regions have the highest churn?
- Which contract types retain customers best?
- Which network quality metrics influence churn?
- Which customers should be targeted for retention campaigns?
- What revenue is currently at risk?
- Which support issues correlate with churn?

This platform answers these questions through an integrated analytics solution.

---

# 🏗 Enterprise Architecture

```
                    RAW DATA SOURCES
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
Customer Data        Network Data      Geographic Data
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    Bronze Layer
             Raw Data Ingestion (Python)
                           │
                           ▼
                    Silver Layer
          Cleaning • Validation • Standardization
                           │
                           ▼
                     Gold Layer
             PostgreSQL Data Warehouse
                    (Star Schema)
                           │
                           ▼
                 SQL Analytics Layer
            Views • KPIs • Business Queries
                           │
          ┌────────────────┴─────────────────┐
          │                                  │
          ▼                                  ▼
   Power BI Dashboards              Machine Learning
                                    Churn Prediction
```

---

# 🏢 Business Process

```
Customers
      │
Purchase Telecom Plans
      │
Generate Monthly Bills
      │
Make Payments
      │
Contact Customer Support
      │
Use Telecom Network
      │
Generate Operational Data
      │
ETL Processing
      │
Data Warehouse
      │
Business Analytics
      │
Executive Decision Making
```

---

# 📂 Data Sources

| # | Dataset | Purpose | Records |
|---|---------|---------|---------|
| 1 | IBM Telco Customer Churn | Customer master dataset | 7,043 |
| 2 | IBM Telco Customer Churn (Extended) | CLTV, Churn Score, Geography | 7,043 |
| 3 | Pakistan Cities Dataset | Geographic Dimension | 146 |
| 4 | Date Dimension | Calendar Dimension | 4,748 |
| 5 | OpenCelliD Pakistan (MCC 410) | Telecom Tower Infrastructure | 4,225 |

> **Note**
>
> IBM's original customer dataset contains U.S. customer locations.
>
> For demonstration purposes, customers are assigned randomized Pakistani cities so the warehouse can demonstrate complete geographic analytics.
>
> In production systems, customer geography would come directly from operational CRM systems.

---

# ⭐ Star Schema Design

## Fact Table Grain

**fact_customer_snapshot**

One row represents:

> One Customer × One Month

This allows:

- Monthly Revenue Analysis
- Monthly Churn Analysis
- Customer Lifetime Tracking
- Monthly KPI Reporting
- Machine Learning Feature Generation

---

# 🌟 Star Schema

```
                    ┌───────────────────┐
                    │     dim_date      │
                    └─────────┬─────────┘
                              │
                              │
      ┌───────────────┐   ┌────▼────────────────────┐   ┌───────────────┐
      │ dim_customer  ├──►│ fact_customer_snapshot │◄──┤   dim_plan    │
      └───────────────┘   └────▲────────────────────┘   └───────────────┘
                               │
                               │
         ┌─────────────────────┼──────────────────────┐
         │                     │                      │
         ▼                     ▼                      ▼
   dim_city              dim_tower            dim_date

                fact_payment        fact_support
```

---

# 📋 Data Warehouse Tables

| Table | Type | Grain |
|------|------|------|
| dim_customer | Dimension | One row per customer |
| dim_plan | Dimension | One row per plan |
| dim_city | Dimension | One row per city |
| dim_date | Dimension | One row per day |
| dim_tower | Dimension | One row per telecom tower |
| fact_customer_snapshot | Fact | One row per customer per month |
| fact_payment | Fact | One row per payment |
| fact_support | Fact | One row per support ticket |

---

# 🛠 Technology Stack

| Layer | Technology |
|---------|------------|
| Programming | Python 3.11 |
| Database | PostgreSQL 17 |
| ETL | Pandas, SQLAlchemy, psycopg2 |
| Data Warehouse | Star Schema |
| Analytics | SQL |
| Machine Learning | Scikit-learn, XGBoost |
| Dashboard | Power BI Desktop |
| Version Control | Git & GitHub |
| Documentation | Markdown |

---

# 📁 Project Structure

```text
telecom-customer-analytics-platform/
│
├── data/
│   └── raw/
│       ├── WA_Fn-UseC_-Telco-Customer-Churn.csv
│       ├── Telco_customer_churn.xlsx
│       ├── pk.csv
│       └── 410.csv
│
├── database/
│   ├── V001__create_database.sql
│   ├── V002__create_schemas.sql
│   ├── V003__create_dim_tables.sql
│   ├── V004__create_fact_tables.sql
│   ├── V005__create_indexes.sql
│   └── V006__create_unknown_records.sql
│
├── docs/
│   ├── business_process.md
│   ├── dataset_inventory.md
│   ├── dimension_design.md
│   ├── fact_design.md
│   ├── fact_table_grain.md
│   ├── key_strategy.md
│   ├── kpi_catalog.md
│   ├── source_mapping.md
│   ├── star_schema_design.md
│   └── transformation_rules.md
│
├── etl/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── config.py
│
├── sql/
│   ├── V001__customer_analytics.sql
│   ├── V002__revenue_analytics.sql
│   ├── V003__churn_analytics.sql
│   ├── V004__network_analytics.sql
│   ├── V005__geographic_analytics.sql
│   ├── V006__payment_analytics.sql
│   ├── V007__support_analytics.sql
│   ├── V008__executive_kpis.sql
│   └── V009__analytical_views.sql
│
├── ml/
│   ├── churn_model.py
│   └── outputs/
│       ├── churn_model.pkl
│       ├── model_results.csv
│       └── feature_importance.csv
│
├── powerbi/
│   ├── telecom_dashboard.pbix
│   └── telecom_theme.json
│
├── images/
│   ├── 01_executive_summary.png.png
│   ├── 02_customer_analytics.png.png
│   ├── 03_churn_analysis.png.png
│   ├── 04_revenue_analysis.png.png
│   ├── 05_network_performance.png.png
│   ├── 06_support_payments.png.png
│   ├── Data Model.png.png
│   ├── Sementic model.png.png
│   └── data tables.png.png
│
├── notebooks/
│   ├── data_profiling_notebook.ipynb
│   └── profiling_outputs/
│
├── requirements.txt
├── README.md
└── .gitignore
```

> **Note:** The image filenames above match your current repository. If you later rename them to remove the duplicate `.png`, update the README image paths accordingly.

---

# 📊 Power BI Dashboard

The Power BI solution consists of six interactive dashboard pages built using a professional dark theme with KPI cards, slicers, drill-through navigation, bookmarks, and DAX measures.

The dashboards are connected directly to the PostgreSQL Data Warehouse.

---

## Dashboard Pages

| Dashboard | Purpose |
|------------|---------|
| Executive Summary | Overall company KPIs |
| Customer Analytics | Customer segmentation and demographics |
| Churn Analysis | Churn behaviour and churn drivers |
| Revenue Analysis | Revenue trends and customer value |
| Network Performance | Tower analytics and network KPIs |
| Support & Payments | Support tickets and payment analysis |

---

# 📸 Dashboard Screenshots

## Executive Summary

![Executive Dashboard](images/01_executive_summary.png)

---

## Customer Analytics

![Customer Analytics](images/02_customer_analytics.png)

---

## Churn Analysis

![Churn Analysis](images/03_churn_analysis.png)

---

## Revenue Analysis

![Revenue Analysis](images/04_revenue_analysis.png)

---

## Network Performance

![Network Performance](images/05_network_performance.png)

---

## Support & Payments

![Support Dashboard](images/06_support_payments.png)

---

# 🗄 Data Warehouse Model

## Physical Data Model

![Data Model](images/Data%20Model.png.png)

---

## Semantic Model

![Semantic Model](images/Sementic%20model.png.png)

---

## Source Tables

![Source Tables](images/data%20tables.png.png)

---

# 📈 SQL Analytics

The warehouse contains a collection of analytical SQL scripts covering multiple business domains.

### Customer Analytics

- Customer segmentation
- Customer demographics
- Customer tenure
- Contract distribution
- Internet service usage

---

### Revenue Analytics

- Monthly revenue
- Revenue by contract
- Revenue by payment method
- Revenue by city
- Revenue by customer segment

---

### Churn Analytics

- Churn rate
- Churn reasons
- Churn by gender
- Churn by contract
- Churn by internet service
- Churn by city
- Churn by tenure

---

### Network Analytics

- Tower density
- Radio technology distribution
- Average network score
- Signal quality
- Latency analysis

---

### Geographic Analytics

- Customer distribution
- Revenue by city
- Churn by city
- Regional performance

---

### Payment Analytics

- Payment method analysis
- Monthly payment trends
- Outstanding revenue
- Payment success rate

---

### Support Analytics

- Ticket volume
- Resolution status
- Average resolution time
- Support category analysis

---

### Executive KPIs

The SQL layer produces KPIs such as:

- Total Customers
- Active Customers
- Churn Rate
- Monthly Revenue
- Annual Revenue
- Customer Lifetime Value
- Average Monthly Charges
- Average Tenure
- Revenue at Risk
- Support Ticket Count

---

# 🤖 Machine Learning

The project includes a complete machine learning pipeline for customer churn prediction.

The model is trained using engineered features extracted directly from the Gold Layer Data Warehouse.

---

## Algorithms Evaluated

- Logistic Regression
- Random Forest
- XGBoost

The best-performing model is XGBoost.

---

## Model Performance

| Metric | Random Forest | XGBoost |
|---------|--------------:|---------:|
| Accuracy | 93.97% | 93.54% |
| Precision | 90.48% | 87.73% |
| Recall | 86.36% | 87.97% |
| F1 Score | 88.37% | 87.85% |
| ROC AUC | 96.94% | **98.31%** |

---

## Top Predictive Features

1. Churn Score
2. Contract Type
3. Tenure
4. Total Charges
5. Monthly Charges
6. Internet Service
7. Payment Method
8. Tech Support
9. Online Security
10. Customer Lifetime Value

---

## Machine Learning Outputs

```
ml/
└── outputs/
    ├── churn_model.pkl
    ├── feature_importance.csv
    └── model_results.csv
```

---

# 📚 Documentation

Complete project documentation is available inside the `docs/` directory.

Included documentation:

- Business Process
- Dataset Inventory
- Star Schema Design
- Source Mapping
- KPI Catalog
- Transformation Rules
- Fact Table Design
- Dimension Design
- Key Strategy
- Fact Table Grain

---

# 📋 Data Quality

The ETL pipeline performs:

- Duplicate removal
- Missing value handling
- Data type validation
- Standardization
- Business rule validation
- Unknown member handling
- Logging rejected records

Rejected records are stored inside:

```
logs/rejected_records.csv
```