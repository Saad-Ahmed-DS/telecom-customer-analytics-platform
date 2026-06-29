# Star Schema Design

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines the dimensional model used in the Telecom Customer Analytics & Churn Intelligence Platform.

The warehouse follows the **Kimball Star Schema** methodology to optimize analytical queries, dashboard performance, machine learning feature generation, and future scalability.

The warehouse is centered around a **Monthly Customer Snapshot Fact**, which represents the complete business state of a customer for a given month.

---

# Why Star Schema?

A Star Schema was selected because it provides:

- Fast analytical queries
- Simple SQL joins
- Excellent Power BI performance
- Easy maintenance
- Scalable architecture
- Business-friendly data model

Unlike OLTP databases, this warehouse is optimized for analytics and decision support.

---

# Warehouse Architecture

```
                           +----------------+
                           |    dim_date    |
                           +----------------+
                                   |
                                   |
        +---------------+----------+-----------+---------------+
        |               |                      |               |
+---------------+ +--------------+ +----------------+ +---------------+
| dim_customer  | |   dim_plan   | |    dim_city    | |   dim_tower   |
+---------------+ +--------------+ +----------------+ +---------------+
        \               |                  |                /
         \              |                  |               /
          \             |                  |              /
           \            |                  |             /
            +------------------------------------------+
            |      fact_customer_snapshot              |
            +------------------------------------------+
                          |
          +---------------+---------------+
          |                               |
+--------------------+          +------------------+
|    fact_payment    |          |   fact_support   |
+--------------------+          +------------------+
```

---

# Dimension Tables

## dim_customer

Stores customer demographic information.

Primary Key

```
customer_key
```

Business Key

```
customer_id
```

---

## dim_plan

Stores subscription and service information.

Primary Key

```
plan_key
```

---

## dim_city

Stores customer geographic information.

Primary Key

```
city_key
```

---

## dim_date

Stores calendar attributes.

Primary Key

```
date_key
```

---

## dim_tower

Stores mobile network tower information.

Primary Key

```
tower_key
```

---

# Fact Tables

## 1. fact_customer_snapshot

### Business Purpose

Central analytical fact table.

One row represents one customer's complete business snapshot for one calendar month.

### Measures

Financial

- monthly_charge
- total_charge

Usage

- data_usage_gb
- voice_minutes
- sms_count
- roaming_minutes
- international_minutes

Network

- signal_strength
- latency_ms
- packet_loss_percent
- downtime_minutes
- network_score

Customer Analytics

- tenure_months
- churn_flag
- churn_score
- cltv

---

## 2. fact_payment

### Business Purpose

Stores customer payment transactions.

### Measures

- payment_amount
- payment_status
- payment_method
- late_payment_days

---

## 3. fact_support

### Business Purpose

Stores customer support interactions.

### Measures

- issue_type
- priority
- resolution_time_hours
- ticket_status

---

# Relationships

## dim_customer

Connected to

- fact_customer_snapshot
- fact_payment
- fact_support

Relationship

```
One Customer

↓

Many Fact Records
```

---

## dim_date

Connected to

- fact_customer_snapshot
- fact_payment
- fact_support

---

## dim_plan

Connected to

- fact_customer_snapshot

---

## dim_city

Connected to

- fact_customer_snapshot
- fact_support

---

## dim_tower

Connected to

- fact_customer_snapshot

---

# Cardinality

| Relationship | Cardinality |
|--------------|------------|
| Customer → Snapshot | 1 : Many |
| Customer → Payment | 1 : Many |
| Customer → Support | 1 : Many |
| Date → Snapshot | 1 : Many |
| Date → Payment | 1 : Many |
| Date → Support | 1 : Many |
| Plan → Snapshot | 1 : Many |
| City → Snapshot | 1 : Many |
| Tower → Snapshot | 1 : Many |

---

# Fact Table Grain

| Fact Table | Grain |
|------------|------------------------------|
| fact_customer_snapshot | One Customer per Month |
| fact_payment | One Payment Transaction |
| fact_support | One Support Ticket |

---

# Warehouse Layers

The project follows the Medallion Architecture.

```
Bronze
│
├── Raw Source Files
│
▼

Silver
│
├── Cleaned & Validated Data
│
▼

Gold
│
├── Dimension Tables
├── Fact Tables
├── Analytical Views
├── Power BI
├── Machine Learning
```

---

# Naming Standards

## Dimension Tables

```
dim_customer
dim_plan
dim_city
dim_date
dim_tower
```

---

## Fact Tables

```
fact_customer_snapshot
fact_payment
fact_support
```

---

## Primary Keys

```
*_key
```

---

## Business Keys

```
*_id
```

---

# Design Principles

The warehouse follows these enterprise principles:

- Kimball Star Schema
- Central Monthly Snapshot Fact
- Transactional Supporting Facts
- Surrogate Keys
- One Grain per Fact Table
- Referential Integrity
- Data Quality Validation
- ETL Traceability
- Future Slowly Changing Dimensions (SCD Type 2)

---

# Future Enhancements

The warehouse can later support:

- Daily customer snapshots
- Call Detail Records (CDR)
- Recharge transactions
- Campaign response analytics
- Device usage analytics
- Materialized views
- Aggregate fact tables
- Incremental ETL
- Streaming data pipelines
- Slowly Changing Dimensions (Type 2)

---

# Summary

The Telecom Customer Analytics & Churn Intelligence Platform uses an enterprise-grade Kimball Star Schema centered around **fact_customer_snapshot**, which serves as the analytical backbone of the warehouse.

Supporting transactional fact tables (**fact_payment** and **fact_support**) provide detailed operational insights while keeping the analytical model simple, scalable, and optimized for SQL analytics, Power BI dashboards, KPI reporting, and machine learning.