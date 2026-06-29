# Transformation Rules

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines all data transformation, validation, standardization, enrichment, and feature engineering rules applied during the ETL process.

Every record loaded into the warehouse must follow these rules to ensure:

- Data Quality
- Consistency
- Accuracy
- Integrity
- Reproducibility

These transformations are applied during the **Bronze → Silver → Gold** ETL pipeline.

---

# ETL Pipeline

```
Raw Data (Bronze)
        │
        ▼
Cleaning & Validation
        │
        ▼
Standardization (Silver)
        │
        ▼
Business Transformation
        │
        ▼
Feature Engineering
        │
        ▼
Warehouse Tables (Gold)
```

---

# General Transformation Rules

| Rule | Description |
|-------|-------------|
| Trim Spaces | Remove leading/trailing spaces |
| Remove Duplicates | Remove duplicate records |
| Standardize Nulls | Blank strings → NULL |
| Validate Data Types | Convert to correct datatype |
| Standardize Text | Proper Case where appropriate |
| Remove Invalid Characters | Remove unwanted symbols |
| Validate Keys | Ensure business keys are unique |
| Foreign Key Validation | Validate surrogate key lookups |

---

# Dataset 1 – IBM Telco Customer Churn

## customerID

Transformation

```
Trim
Uppercase
Validate Uniqueness
```

Destination

```
dim_customer.customer_id
```

---

## SeniorCitizen

```
0 → FALSE
1 → TRUE
```

---

## Partner

```
Yes → TRUE
No → FALSE
```

---

## Dependents

```
Yes → TRUE
No → FALSE
```

---

## MonthlyCharges

Validation

- Must be ≥ 0
- Numeric(10,2)

Destination

```
fact_customer_snapshot.monthly_charge
```

---

## TotalCharges

Transformation

```
Trim
Blank → NULL
Convert to NUMERIC
```

Destination

```
fact_customer_snapshot.total_charge
```

---

## tenure

Destination

```
fact_customer_snapshot.tenure_months
```

Validation

```
>= 0
```

---

# Dataset 2 – IBM Telco Extended

## Churn Value

```
0 → FALSE
1 → TRUE
```

Destination

```
fact_customer_snapshot.churn_flag
```

---

## Churn Score

Validation

```
0–100
```

Destination

```
fact_customer_snapshot.churn_score
```

---

## CLTV

Validation

```
Positive Integer
```

Destination

```
fact_customer_snapshot.cltv
```

---

## Latitude

Validation

```
-90 ≤ latitude ≤ 90
```

---

## Longitude

Validation

```
-180 ≤ longitude ≤ 180
```

---

# Dataset 3 – Pakistan Cities

## City

Transformation

```
Trim
Proper Case
Remove Double Spaces
```

---

## Province

Transformation

```
Proper Case
Validate Province List
```

---

## Population

Validation

```
Population > 0
```

---

# Dataset 4 – Date Dimension

Generated during ETL.

Columns

```
date_key
full_date
day
week
month
quarter
year
month_name
day_name
is_weekend
is_holiday
```

---

# Dataset 5 – OpenCellID

## Radio

Allowed Values

```
LTE
GSM
UMTS
NR
CDMA
```

Invalid values become

```
Unknown
```

---

## Coordinates

Latitude

```
-90 ≤ latitude ≤ 90
```

Longitude

```
-180 ≤ longitude ≤ 180
```

---

# Generated Business Metrics

The ETL creates additional analytical metrics.

## Usage Metrics

Generated

```
data_usage_gb
voice_minutes
sms_count
roaming_minutes
international_minutes
```

Stored in

```
fact_customer_snapshot
```

---

## Network Metrics

Generated

```
signal_strength
latency_ms
packet_loss_percent
downtime_minutes
network_score
```

Stored in

```
fact_customer_snapshot
```

---

## Payment Transactions

Generated

```
payment_amount
payment_method
payment_status
late_payment_days
```

Stored in

```
fact_payment
```

---

## Support Tickets

Generated

```
issue_type
priority
resolution_time_hours
ticket_status
```

Stored in

```
fact_support
```

---

# Derived Business Features

Generated during ETL.

## Revenue Category

```
Low
Medium
High
```

---

## Usage Segment

```
Light
Moderate
Heavy
```

---

## Customer Segment

```
New
Growing
Loyal
VIP
```

---

## Risk Category

Based on

- Churn Score
- CLTV
- Support Activity

Values

```
Low Risk
Medium Risk
High Risk
```

---

# Business Rules

## Customer

One customer must have one unique customer_id.

---

## Monthly Charge

```
>= 0
```

---

## Payment Amount

```
>= 0
```

---

## Resolution Time

```
>= 0
```

---

## Network Score

```
0–100
```

---

# Missing Value Strategy

| Situation | Action |
|------------|---------|
| Missing Business Key | Reject |
| Optional Attribute Missing | NULL |
| Blank String | NULL |
| Invalid Number | Reject |
| Invalid Date | Reject |

---

# Duplicate Strategy

| Dataset | Rule |
|----------|------|
| Customer | customer_id unique |
| Cities | city + province unique |
| Towers | mcc + net + area + cell unique |

---

# Data Quality Rules

Every ETL execution performs:

## Completeness

- Required fields populated
- Primary keys not NULL

---

## Accuracy

- Numeric ranges validated
- Coordinates validated
- Churn values validated

---

## Consistency

- Consistent customer identifiers
- Standardized city names

---

## Uniqueness

- Primary keys unique
- Business keys unique

---

## Validity

- Contract values valid
- Radio technology valid
- Payment status valid

---

# Error Handling

Rejected records are written to

```
logs/rejected_records.csv
```

Each record contains

- Dataset
- Row Number
- Error
- Timestamp

---

# Logging

Each ETL execution logs

- Start Time
- End Time
- Records Read
- Records Loaded
- Records Rejected
- Execution Duration

---

# Summary

These transformation rules ensure that all data entering the warehouse is clean, standardized, validated, and enriched.

The ETL pipeline produces one central analytical snapshot table (**fact_customer_snapshot**) and two transactional fact tables (**fact_payment** and **fact_support**) that together support SQL analytics, Power BI dashboards, KPI reporting, and machine learning.