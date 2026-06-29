# Dimension Table Design

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines all dimension tables used in the Telecom Customer Analytics & Churn Intelligence Platform.

Dimension tables store descriptive business information that provides context to measurable events stored in fact tables.

Each dimension is assigned a surrogate key and is designed according to dimensional modeling (Kimball Star Schema) principles.

---

# What is a Dimension Table?
Dimension tables store descriptive business information that provides context to both periodic snapshot facts and transactional fact tables.

The warehouse follows a hybrid dimensional model consisting of:

- One central Periodic Snapshot Fact Table
- Two Transaction Fact Tables

Examples include:

- Customer
- City
- Date
- Service Plan
- Network Tower

Dimension tables change slowly compared to transactional data and provide context for analytical reporting.

---

# Dimension Overview

|| Dimension    | Purpose                 | Source                                                         |
| ------------ | ----------------------- | -------------------------------------------------------------- |
| dim_customer | Customer profile        | IBM Telco Extended (Primary) + IBM Telco Customer (Validation) |
| dim_plan     | Subscription & Services | IBM Telco Customer                                             |
| dim_city     | Geographic information  | Pakistan Cities + IBM Extended                                 |
| dim_date     | Calendar                | Generated                                                      |
| dim_tower    | Network Infrastructure  | OpenCellID                                                     |



---

# 1. dim_customer

## Business Purpose

Stores demographic and customer profile information.

One record represents one customer.

---

## Primary Key

customer_key (Surrogate Key)

---

## Business Key

customer_id

---

## Attributes

| Column         | Description                  |
| -------------- | ---------------------------- |
| customer_key   | Warehouse surrogate key      |
| customer_id    | Original customer identifier |
| gender         | Customer gender              |
| senior_citizen | Senior citizen indicator     |
| partner        | Partner status               |
| dependents     | Dependents status            |


---

## Slowly Changing Dimension

Type 2 (Future Enhancement)

If customer profile changes, historical versions may be preserved.

---

# 2. dim_plan

## Business Purpose

Stores telecom subscription details.

This dimension avoids repeating plan information across multiple fact tables.

---

## Primary Key

plan_key

---

## Attributes

| Column | Description |
|----------|-------------|
| plan_key | Warehouse key |
| phone_service | Phone Service |
| multiple_lines | Multiple Lines |
| internet_service | Internet Type |
| online_security | Online Security |
| online_backup | Online Backup |
| device_protection | Device Protection |
| tech_support | Tech Support |
| streaming_tv | Streaming TV |
| streaming_movies | Streaming Movies |
| contract | Contract Type |
| paperless_billing | Paperless Billing |

---

# 3. dim_city

## Business Purpose

Stores geographical information.

Used for regional reporting and map visualizations.

---

## Primary Key

city_key

---

## Attributes

| Column | Description |
|----------|-------------|
| city_key | Warehouse key |
| city | City Name |
| province | Province |
| latitude | Latitude |
| longitude | Longitude |
| population | Population |

---

# 4. dim_date

## Business Purpose

Supports time-based analysis.

This table will be generated programmatically during ETL.

---

## Primary Key

date_key

---

## Attributes

| Column | Description |
|----------|-------------|
| date_key | YYYYMMDD |
| full_date | Date |
| day | Day Number |
| day_name | Monday, Tuesday... |
| week | Week Number |
| month | Month Number |
| month_name | January |
| quarter | Quarter |
| year | Calendar Year |
| is_weekend | Boolean |
| is_holiday | Boolean |

---

# 5. dim_tower

## Business Purpose

Stores network infrastructure information.

Used for network performance analysis.

---

## Primary Key

tower_key

---

## Business Key

Composite

- mcc
- net
- area
- cell

---

## Attributes

| Column | Description |
|----------|-------------|
| tower_key | Warehouse key |
| mcc | Mobile Country Code |
| net | Mobile Network Code |
| area | Location Area Code |
| cell | Cell Identifier |
| radio | Radio Technology |
| longitude | Longitude |
| latitude | Latitude |
| range | Tower Coverage |
| samples | Number of Samples |

---

# Dimension Relationships

                    dim_date
                        │
                        │
                        ▼
             fact_customer_snapshot
       ┌────────┼────────┬─────────┐
       ▼        ▼        ▼         ▼
dim_customer dim_plan dim_city dim_tower
                     │
          ┌──────────┴───────────┐
          ▼                      ▼
    fact_payment          fact_support
---

# Fact Relationships

The warehouse contains three fact tables.

## fact_customer_snapshot

Connected Dimensions

- dim_customer
- dim_date
- dim_plan
- dim_city
- dim_tower

Purpose

Stores one monthly business snapshot for every customer.

---

## fact_payment

Connected Dimensions

- dim_customer
- dim_date

Purpose

Stores payment transactions.

---

## fact_support

Connected Dimensions

- dim_customer
- dim_date
- dim_city

Purpose

Stores customer support tickets.

# Design Standards

The following standards are used across all dimensions.

## Naming Convention

Primary Keys

```

customer_key

city_key

plan_key

date_key

tower_key

```

Business Keys

```

customer_id

```

Foreign Keys

```

customer_key

city_key

plan_key

date_key

tower_key

```

---

# Slowly Changing Dimensions (SCD)

| Dimension | Type |
|------------|------|
| dim_customer | Type 2 (Future) |
| dim_plan | Type 1 |
| dim_city | Type 1 |
| dim_date | Static |
| dim_tower | Type 1 |

---

# Design Principles

The warehouse follows the following dimensional modeling principles:

- Surrogate keys for all dimensions
- Business keys retained for traceability
- Descriptive attributes stored in dimensions
- Time-varying business metrics are stored in fact tables, while descriptive attributes remain in dimension tables.
- Star schema design
- Future support for Slowly Changing Dimensions

---

# Future Enhancements

The warehouse can later include additional dimensions such as:

- dim_payment_method
- dim_device
- dim_campaign
- dim_employee
- dim_region

These dimensions are outside the scope of Version 1 but have been considered for future scalability.