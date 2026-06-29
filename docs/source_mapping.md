# Source-to-Target Mapping (STM)

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines how data from the source datasets is transformed and loaded into the PostgreSQL Data Warehouse.

It serves as the ETL blueprint by documenting:

- Source dataset
- Source column
- Destination table
- Destination column
- Transformation rules
- Data type conversion
- Business notes

The mapping ensures consistency, traceability, and maintainability throughout the project.

---

# Source Datasets

| Dataset | Purpose |
|----------|---------|
| IBM Telco Customer Churn | Customer & Service Information |
| IBM Telco Customer Churn (Extended) | Customer Analytics & Churn Metrics |
| Pakistan Cities | Geographic Information |
| OpenCellID | Network Infrastructure |
| Generated Date Dimension | Calendar |

---

# ETL Flow

```
Raw CSV Files
      │
      ▼
Staging Tables
      │
      ▼
Data Cleaning & Validation
      │
      ▼
Dimension Tables
      │
      ▼
Fact Tables
      │
      ▼
Power BI / Machine Learning
```

---

# Dataset 1

## IBM Telco Customer Churn

### Destination Tables

- warehouse.dim_customer
- warehouse.dim_plan
- warehouse.fact_customer_snapshot

---

## dim_customer

| Source Column | Destination | Transformation |
|---------------|------------|----------------|
| customerID | customer_id | Direct |
| gender | gender | Trim |
| SeniorCitizen | senior_citizen | 0/1 → Boolean |
| Partner | partner | Yes/No → Boolean |
| Dependents | dependents | Yes/No → Boolean |

---

## dim_plan

| Source Column | Destination |
|---------------|------------|
| PhoneService | phone_service |
| MultipleLines | multiple_lines |
| InternetService | internet_service |
| OnlineSecurity | online_security |
| OnlineBackup | online_backup |
| DeviceProtection | device_protection |
| TechSupport | tech_support |
| StreamingTV | streaming_tv |
| StreamingMovies | streaming_movies |
| Contract | contract |
| PaperlessBilling | paperless_billing |

---

## fact_customer_snapshot

| Source Column | Destination |
|---------------|------------|
| tenure | tenure_months |
| MonthlyCharges | monthly_charge |
| TotalCharges | total_charge |

---

# Dataset 2

## IBM Telco Customer Churn (Extended)

### Destination Tables

- warehouse.fact_customer_snapshot
- warehouse.dim_city

---

## fact_customer_snapshot

| Source Column | Destination |
|---------------|------------|
| Churn Value | churn_flag |
| Churn Score | churn_score |
| CLTV | cltv |

Optional

| Source Column | Destination |
|---------------|------------|
| Churn Reason | churn_reason |

---

## dim_city

| Source Column | Destination |
|---------------|------------|
| City | city |
| Latitude | latitude |
| Longitude | longitude |

---

# Dataset 3

## Pakistan Cities

### Destination

warehouse.dim_city

| Source Column | Destination |
|---------------|------------|
| city | city |
| province | province |
| latitude | latitude |
| longitude | longitude |
| population | population |

---

# Dataset 4

## Generated Calendar

### Destination

warehouse.dim_date

| Generated Column | Destination |
|------------------|------------|
| date_key | date_key |
| full_date | full_date |
| year | year |
| quarter | quarter |
| month | month |
| week | week |
| day | day |
| is_weekend | is_weekend |
| is_holiday | is_holiday |

---

# Dataset 5

## OpenCellID

### Destination

warehouse.dim_tower

| Source Column | Destination |
|---------------|------------|
| mcc | mcc |
| net | network_code |
| area | area_code |
| cell | cell_id |
| radio | radio |
| lon | longitude |
| lat | latitude |
| range | coverage_range |
| samples | sample_count |

---

# Generated Fields

The following values are created during ETL.

## fact_customer_snapshot

Generated

- data_usage_gb
- voice_minutes
- sms_count
- roaming_minutes
- international_minutes

Generated

- signal_strength
- latency_ms
- packet_loss_percent
- downtime_minutes
- network_score

Generated

- revenue_category
- usage_segment
- customer_segment

---

## fact_payment

Generated using business rules

Columns

- payment_amount
- payment_method
- payment_status
- late_payment_days

---

## fact_support

Generated using business rules

Columns

- issue_type
- priority
- resolution_time_hours
- ticket_status

---

# Data Lineage

IBM Customer

↓

dim_customer

↓

fact_customer_snapshot

↓

Power BI

↓

Machine Learning

---

IBM Extended

↓

fact_customer_snapshot

↓

Customer Analytics

---

Pakistan Cities

↓

dim_city

↓

Regional Analysis

---

OpenCellID

↓

dim_tower

↓

fact_customer_snapshot

↓

Network Analytics

---

# Mapping Standards

The following standards apply.

- One source column maps to one destination whenever possible.
- Data types are standardized during ETL.
- Business keys are preserved.
- Surrogate keys are generated after loading dimensions.
- Generated fields are documented separately.
- Every mapping is traceable back to its source dataset.

---

# Summary

The Source-to-Target Mapping document defines how raw telecom datasets are transformed into a clean, analytics-ready PostgreSQL warehouse.

The **fact_customer_snapshot** table serves as the central destination for customer analytics, while **fact_payment** and **fact_support** are generated transaction tables that enrich the warehouse for realistic reporting and analysis.