# Key Strategy

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines the key management strategy used throughout the Telecom Customer Analytics & Churn Intelligence Platform.

A consistent key strategy ensures:

- Reliable joins between tables
- Better query performance
- Historical data support
- Easier ETL implementation
- Scalability
- Data integrity

The warehouse follows Kimball dimensional modeling principles and uses surrogate keys for all dimension and fact tables.

---

# Types of Keys

The warehouse uses the following key types:

| Key Type | Purpose |
|----------|---------|
| Surrogate Key | Internal warehouse identifier |
| Business Key | Original identifier from source system |
| Primary Key | Uniquely identifies each row |
| Foreign Key | Creates relationships between tables |
| Composite Key | Used only in staging when necessary |

---

# Surrogate Keys

## Definition

A surrogate key is a system-generated integer that uniquely identifies a record inside the warehouse.

It has no business meaning and never changes.

Example

Instead of

```
customerID = 7590-VHVEG
```

The warehouse stores

```
customer_key = 1024
```

---

# Why Use Surrogate Keys?

Business keys may:

- Change over time
- Have different formats
- Be duplicated across systems
- Be difficult to join efficiently

Surrogate keys provide:

- Faster joins
- Smaller indexes
- Consistent relationships
- Better warehouse performance

---

# Dimension Key Strategy

## dim_customer

| Key | Type |
|------|------|
| customer_key | Surrogate Primary Key |
| customer_id | Business Key |

---

## dim_plan

| Key | Type |
|------|------|
| plan_key | Surrogate Primary Key |

---

## dim_city

| Key | Type |
|------|------|
| city_key | Surrogate Primary Key |

---

## dim_date

| Key | Type |
|------|------|
| date_key | Surrogate Primary Key |

Format

```
YYYYMMDD

Example

20260115
```

---

## dim_tower

| Key | Type |
|------|------|
| tower_key | Surrogate Primary Key |

Business Key

```
(mcc, net, area, cell)
```

is retained only for traceability.

---

# Fact Table Key Strategy

Each fact table has its own surrogate primary key.

| Fact Table | Primary Key |
|------------|-------------|
| fact_customer_snapshot | snapshot_key |
| fact_payment | payment_key |
| fact_support | ticket_key |

---

# Foreign Key Relationships

## fact_customer_snapshot

```
customer_key

date_key

city_key

plan_key

tower_key
```

---

## fact_payment

```
customer_key

date_key
```

---

## fact_support

```
customer_key

date_key

city_key
```

Business keys are never stored inside fact tables.

---

# Key Naming Convention

## Primary Keys

```
customer_key
plan_key
city_key
date_key
tower_key

snapshot_key
payment_key
ticket_key
```

---

## Foreign Keys

```
customer_key
plan_key
city_key
date_key
tower_key
```

---

## Business Keys

```
customer_id
```

---

# Auto Increment Strategy

All surrogate keys will be generated automatically by PostgreSQL using

```
GENERATED ALWAYS AS IDENTITY
```

This is the recommended approach for PostgreSQL 10+.

---

# Composite Keys

Composite keys will never exist inside the warehouse.

The only exception is during staging.

Example

OpenCellID

```
mcc
net
area
cell
```

During ETL these fields are converted into

```
tower_key
```

---

# Referential Integrity

Every foreign key must reference an existing dimension record.

Example

```
fact_customer_snapshot.customer_key

↓

dim_customer.customer_key
```

Invalid foreign keys are rejected during ETL.

---

# Unknown Records

Each dimension contains one default record.

Example

| Key | Value |
|------|-------|
| -1 | Unknown |

If a lookup fails during ETL

```
customer_key = -1
```

instead of NULL.

This preserves referential integrity and simplifies reporting.

---

# Indexing Strategy

Primary Keys

Automatically indexed.

Additional indexes

- customer_key
- date_key
- city_key
- plan_key
- tower_key

Composite indexes

```
(customer_key, date_key)

(date_key, city_key)

(city_key, tower_key)
```

These improve analytical SQL queries and Power BI performance.

---

# Design Principles

The warehouse follows these principles:

- Every dimension has a surrogate key.
- Business keys are preserved for traceability.
- Fact tables store only surrogate foreign keys.
- Composite keys remain only in staging.
- Unknown records prevent NULL foreign keys.
- Naming conventions remain consistent across the warehouse.
- Snapshot and transaction facts follow the same key strategy.

---

# Summary

The warehouse uses surrogate keys across all dimensions and fact tables to ensure scalability, performance, and maintainability.

The central **fact_customer_snapshot** table links all major business dimensions, while **fact_payment** and **fact_support** maintain transactional relationships.

This strategy provides a clean, enterprise-grade foundation for ETL, SQL analytics, Power BI dashboards, and machine learning workflows.