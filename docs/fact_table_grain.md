# Fact Table Grain

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines the **grain (lowest level of detail)** for every fact table in the data warehouse.

The grain determines what a single row in a fact table represents.

Defining the grain before implementation ensures consistency across PostgreSQL, ETL, SQL analytics, Power BI dashboards, and Machine Learning workflows.

---

# What is Grain?

The grain answers one simple question:

> **"What does one row represent?"**

Every fact table must have one clearly defined grain.

---

# Fact Tables Overview

| Fact Table | Business Process |
|------------|------------------|
| fact_customer_snapshot | Monthly Customer Analytics |
| fact_payment | Payment Transactions |
| fact_support | Customer Support Tickets |

---

# Grain Definition

## 1. fact_customer_snapshot

### Grain

**One row represents one customer's complete business snapshot for one calendar month.**

### Example

| Customer | Month | Record |
|----------|--------|--------|
| C00001 | Jan-2025 | 1 |
| C00001 | Feb-2025 | 1 |
| C00002 | Jan-2025 | 1 |

---

### Contains

Customer Metrics

- Churn Status
- Churn Score
- CLTV
- Tenure

Billing Metrics

- Monthly Charge
- Total Charge

Usage Metrics

- Data Usage
- Voice Minutes
- SMS Count
- Roaming Minutes

Network Metrics

- Signal Strength
- Latency
- Packet Loss
- Network Score

Derived Metrics

- Revenue Category
- Usage Segment
- Customer Segment

---

## 2. fact_payment

### Grain

**One row represents one payment transaction made by one customer.**

Example

| Customer | Payment Date | Record |
|----------|--------------|--------|
| C00001 | 2025-01-05 | 1 |
| C00001 | 2025-02-04 | 1 |

---

## 3. fact_support

### Grain

**One row represents one customer support ticket.**

Example

| Customer | Ticket ID | Record |
|----------|-----------|--------|
| C00001 | T1001 | 1 |
| C00001 | T1002 | 1 |

---

# Estimated Table Sizes

## Dimension Tables

| Table | Expected Rows |
|--------|--------------:|
| dim_customer | ~7,000 |
| dim_city | ~500 |
| dim_plan | <50 |
| dim_date | ~730 |
| dim_tower | Sampled OpenCellID |

---

## Fact Tables

| Table | Expected Rows |
|--------|--------------:|
| fact_customer_snapshot | Customers × Months |
| fact_payment | Generated Payment Records |
| fact_support | Generated Support Tickets |

---

# Why a Monthly Snapshot?

A periodic snapshot fact table was selected because:

- The source datasets represent customer snapshots rather than detailed transactions.
- Monthly snapshots are the industry standard for telecom customer analytics.
- Simplifies Power BI dashboards.
- Simplifies machine learning feature engineering.
- Reduces unnecessary joins.
- Provides a realistic enterprise data warehouse design.

---

# Design Rules

The following rules apply:

1. Each fact table has one clearly defined grain.
2. Fact tables store measurable business events or snapshots.
3. Dimension tables store descriptive attributes.
4. Fact tables reference dimensions using surrogate keys.
5. All monthly KPIs are calculated from `fact_customer_snapshot`.

---

# Future Enhancements

Future versions may include:

- Daily Usage Fact
- Call Detail Records (CDR)
- Network Event Fact
- Real-Time Streaming Data
- IoT Metrics
- 5G Analytics

---

# Summary

The warehouse uses one central **Periodic Snapshot Fact Table** (`fact_customer_snapshot`) supported by two transactional fact tables (`fact_payment` and `fact_support`).

This hybrid design balances simplicity, scalability, and analytical performance while closely reflecting enterprise telecom data warehouse practices.