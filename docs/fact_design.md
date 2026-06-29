# Fact Table Design

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines the fact tables used in the Telecom Customer Analytics & Churn Intelligence Platform.

Fact tables store measurable business events and periodic business snapshots generated during telecom operations. They contain foreign keys referencing dimension tables along with numeric business metrics used for reporting, SQL analytics, Power BI dashboards, and machine learning.

The warehouse follows the Kimball Star Schema methodology using a hybrid design consisting of:

- One Periodic Snapshot Fact Table
- Two Transaction Fact Tables

---

# What is a Fact Table?

A fact table stores measurable business events or business snapshots.

Examples include:

- Monthly customer snapshot
- Payment transactions
- Customer support tickets

Fact tables contain:

- Surrogate Primary Key
- Foreign Keys
- Numeric Measures
- Derived Metrics

---

# Fact Table Overview

| Fact Table | Business Process | Grain |
|------------|------------------|------------------------------|
| fact_customer_snapshot | Monthly Customer Analytics | One customer per month |
| fact_payment | Customer Payments | One payment transaction |
| fact_support | Customer Support | One support ticket |

---

# 1. fact_customer_snapshot

## Business Purpose

Stores a complete monthly analytical snapshot of every customer.

This is the central fact table of the warehouse and serves as the primary source for reporting, dashboards, KPI calculations, and machine learning.

---

## Grain

One customer for one calendar month.

---

## Primary Key

snapshot_key

---

## Foreign Keys

customer_key

date_key

city_key

plan_key

tower_key

---

## Measures

### Customer Metrics

| Column | Description |
|----------|-------------|
| tenure_months | Customer tenure |
| churn_flag | Churned or not |
| churn_score | Churn prediction score |
| cltv | Customer Lifetime Value |

---

### Billing Metrics

| Column | Description |
|----------|-------------|
| monthly_charge | Monthly subscription charge |
| total_charge | Total accumulated charge |

---

### Usage Metrics *(Generated)*

| Column | Description |
|----------|-------------|
| data_usage_gb | Internet usage |
| voice_minutes | Voice usage |
| sms_count | SMS usage |
| roaming_minutes | Roaming usage |
| international_minutes | International calls |

---

### Network Metrics *(Generated)*

| Column | Description |
|----------|-------------|
| signal_strength | Signal level |
| latency_ms | Network latency |
| packet_loss_percent | Packet loss |
| downtime_minutes | Service downtime |
| network_score | Calculated quality score |

---

### Derived Metrics

| Column | Description |
|----------|-------------|
| revenue_category | Low / Medium / High |
| usage_segment | Light / Moderate / Heavy |
| customer_segment | New / Growing / Loyal / VIP |

---

# 2. fact_payment

## Business Purpose

Stores customer payment transactions.

Supports payment analysis, revenue collection monitoring, and financial reporting.

---

## Grain

One payment transaction.

---

## Primary Key

payment_key

---

## Foreign Keys

customer_key

date_key

---

## Measures

| Column | Description |
|----------|-------------|
| payment_amount | Amount paid |
| payment_status | Paid / Pending / Failed |
| payment_method | Payment method |
| late_payment_days | Days overdue |

---

# 3. fact_support

## Business Purpose

Stores customer support interactions.

Supports operational reporting and customer experience analysis.

---

## Grain

One customer support ticket.

---

## Primary Key

ticket_key

---

## Foreign Keys

customer_key

date_key

city_key

---

## Measures

| Column | Description |
|----------|-------------|
| issue_type | Complaint category |
| priority | Ticket priority |
| resolution_time_hours | Resolution duration |
| ticket_status | Open / Closed |

---

# Fact Table Relationships

| Fact Table | Connected Dimensions |
|------------|----------------------|
| fact_customer_snapshot | Customer, Date, City, Plan, Tower |
| fact_payment | Customer, Date |
| fact_support | Customer, Date, City |

---

# Measure Classification

## Additive

These measures can be summed.

Examples

- Payment Amount
- Data Usage
- Voice Minutes
- SMS Count
- Monthly Revenue
- Downtime

---

## Semi-Additive

Can be summed across dimensions but not time.

Examples

- Total Charges
- CLTV

---

## Non-Additive

Cannot be summed.

Examples

- Churn Score
- Signal Strength
- Network Score
- Latency
- Packet Loss

---

# Fact Table Standards

The following standards apply to every fact table.

- Surrogate primary keys
- Foreign keys reference dimensions
- Numeric measures only
- No descriptive attributes
- Snapshot fact stores monthly business state
- Transaction facts store individual events

---

# Why This Design?

A hybrid fact table architecture was selected because:

- Source datasets provide customer snapshots rather than transactional history.
- A Periodic Snapshot Fact is the industry-standard approach for telecom customer analytics.
- Transactional events such as payments and support tickets remain in separate fact tables.
- Reduces ETL complexity.
- Simplifies Power BI data modeling.
- Simplifies machine learning feature engineering.
- Improves SQL query performance.

---

# Future Expansion

Future versions may include:

- fact_call_detail (CDR)
- fact_data_session
- fact_campaign_response
- fact_device_usage
- fact_recharge
- fact_subscription_change
- fact_network_event

These have been excluded from Version 1 to keep the project focused while maintaining extensibility.

---

# Summary

The warehouse uses one central **Periodic Snapshot Fact Table** (`fact_customer_snapshot`) supported by two **Transactional Fact Tables** (`fact_payment` and `fact_support`).

This architecture provides an enterprise-grade foundation for SQL analytics, Power BI dashboards, KPI reporting, customer segmentation, churn prediction, and executive decision support while remaining scalable for future enhancements.