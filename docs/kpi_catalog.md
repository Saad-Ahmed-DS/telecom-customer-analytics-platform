# KPI Catalog

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

This document defines the Key Performance Indicators (KPIs) used throughout the Telecom Customer Analytics & Churn Intelligence Platform.

The KPI Catalog serves as the primary business reference for measuring organizational performance across customer management, finance, revenue, network operations, customer support, payments, and predictive analytics.

Each KPI includes:

- Business Definition
- Business Value
- Calculation Formula
- Source Table(s)
- Refresh Frequency
- Recommended Visualization

The KPIs defined in this document are designed to support executive reporting, operational monitoring, self-service analytics, and machine learning initiatives.

---

# Objectives

The KPI framework aims to:

- Measure customer behavior and engagement
- Monitor churn and customer retention
- Evaluate financial performance
- Analyze telecom service usage
- Monitor payment collections
- Assess customer support efficiency
- Track network quality
- Enable predictive analytics
- Provide decision support for executives

---

# Data Warehouse Architecture

The KPI framework is built upon the Gold Layer of the Medallion Architecture.

```
Bronze
│
├── Raw Source Files
│
▼
Silver
│
├── Cleaned & Standardized Data
│
▼
Gold
│
├── Star Schema
├── fact_customer_snapshot
├── fact_payment
├── fact_support
│
▼
Power BI
SQL Analytics
Machine Learning
```

---

# Central Fact Table

Unlike traditional telecom warehouses that separate billing, usage, and network information into multiple monthly fact tables, this project adopts a **Monthly Customer Snapshot** architecture.

The central analytical table is:

```
fact_customer_snapshot
```

Each record represents:

> **One Customer × One Calendar Month**

The snapshot combines:

- Customer Status
- Billing Information
- Revenue Metrics
- Usage Metrics
- Network Performance
- Churn Information
- Customer Lifetime Value
- Customer Segments

Additional business processes remain in separate fact tables:

```
fact_payment
fact_support
```

This architecture simplifies analytics while remaining aligned with enterprise telecom data warehouse practices.

---

# KPI Categories

KPIs are organized into eight business domains.

| Category | Business Area |
|-----------|---------------|
| Customer KPIs | Customer Growth & Retention |
| Financial KPIs | Business Performance |
| Revenue KPIs | Revenue Analytics |
| Usage KPIs | Customer Usage Behaviour |
| Payment KPIs | Collections & Billing |
| Support KPIs | Customer Operations |
| Network KPIs | Service Quality |
| Machine Learning KPIs | Predictive Analytics |

---

# Primary Source Tables

| Table | Purpose |
|---------|----------|
| dim_customer | Customer Master Data |
| dim_plan | Subscription Information |
| dim_city | Geographic Analysis |
| dim_date | Time Intelligence |
| dim_tower | Network Infrastructure |
| fact_customer_snapshot | Monthly Customer Analytics |
| fact_payment | Customer Payments |
| fact_support | Customer Support Tickets |

---

# KPI Design Principles

Every KPI in this project follows the same standards.

## 1. Business Driven

Each KPI answers a real business question.

Examples:

- Are customers leaving?
- Which city generates the highest revenue?
- Which customers are most valuable?
- Is network quality improving?

---

## 2. Single Source of Truth

Every KPI has one authoritative source table.

Example

```
Monthly Revenue

Source:
fact_customer_snapshot
```

This eliminates conflicting calculations across reports.

---

## 3. Consistent Definitions

Business formulas remain identical across:

- PostgreSQL
- SQL Views
- Power BI
- Machine Learning

Example

```
Churn Rate

Always equals

Churned Customers
-------------------------
Total Customers
```

No report may redefine KPI calculations.

---

## 4. Time Intelligence

All KPIs support filtering by:

- Year
- Quarter
- Month
- Week
- Date

through

```
dim_date
```

---

## 5. Drill-Down Capability

KPIs can be analyzed by:

- Province
- City
- Contract Type
- Internet Service
- Payment Status
- Customer Segment
- Usage Segment
- Risk Category

---

## 6. Performance Optimized

The Monthly Customer Snapshot minimizes joins and improves dashboard performance.

Most executive dashboards require only:

```
fact_customer_snapshot

+

dim_customer

+

dim_date

+

dim_city

+

dim_plan
```

This reduces query complexity and improves Power BI responsiveness.

---

# KPI Naming Standards

Every KPI follows a consistent naming convention.

Examples

```
Total Revenue

Monthly Revenue

Average Revenue Per User

Customer Growth Rate

Average CLTV

Payment Success Rate

Average Resolution Time

Network Health Index
```

Names are business-friendly and suitable for executive dashboards.

---

# Calculation Standards

Unless otherwise specified:

- Revenue values are displayed in PKR.
- Percentages are rounded to two decimal places.
- Monetary values use Decimal(18,2).
- Rates are calculated using active customer counts.
- Monthly metrics use the latest available customer snapshot.

---

# Visualization Standards

The following visualization guidelines will be used throughout the project.

| KPI Type | Recommended Visualization |
|-----------|---------------------------|
| Single Metric | KPI Card |
| Time Trend | Line Chart |
| Comparison | Clustered Column Chart |
| Distribution | Donut Chart |
| Geographic Analysis | Filled Map |
| Ranking | Horizontal Bar Chart |
| Correlation | Scatter Plot |
| Customer Detail | Table / Matrix |
| Network Monitoring | Gauge |
| ML Evaluation | ROC Curve / Confusion Matrix |

---

# Refresh Strategy

| Layer | Refresh Frequency |
|---------|------------------|
| Bronze | Manual Import |
| Silver | During ETL Execution |
| Gold | After Successful ETL |
| SQL Views | Automatic |
| Power BI Dataset | Scheduled Refresh |

---

# Next Section

The next section introduces **Customer KPIs**, including customer growth, retention, churn, segmentation, and lifetime value metrics that form the foundation of executive reporting.

# Customer KPIs

Customer KPIs measure customer acquisition, retention, loyalty, engagement, and overall customer health.

These metrics are primarily sourced from:

- fact_customer_snapshot
- dim_customer
- dim_date
- dim_city
- dim_plan

Customer KPIs help business leaders understand customer growth, churn behavior, contract distribution, and long-term customer value.

---

# 1. Total Customers

## Business Definition

The total number of unique customers registered in the telecom system.

## Business Value

Measures the overall customer base and serves as the denominator for many other KPIs.

## Formula

```
COUNT(DISTINCT customer_key)
```

## Source

```
dim_customer
```

## Refresh

Monthly

## Visualization

- KPI Card

---

# 2. Active Customers

## Business Definition

Customers who remain active during the reporting month and have not churned.

## Business Value

Measures the size of the active subscriber base.

## Formula

```
COUNT(customer_key)

WHERE churn_flag = FALSE
```

## Source

```
fact_customer_snapshot
```

## Visualization

- KPI Card

---

# 3. Churned Customers

## Business Definition

Customers who left the telecom company during the reporting period.

## Business Value

Measures customer attrition.

## Formula

```
COUNT(customer_key)

WHERE churn_flag = TRUE
```

## Source

```
fact_customer_snapshot
```

## Visualization

- KPI Card

---

# 4. Customer Growth Rate

## Business Definition

Percentage increase in active customers compared to the previous reporting period.

## Business Value

Measures business expansion.

## Formula

```
(New Customers - Churned Customers)

-------------------------------------

Previous Month Customers
```

## Source

```
fact_customer_snapshot
```

## Visualization

- Line Chart

---

# 5. Customer Retention Rate

## Business Definition

Percentage of customers retained during the reporting period.

## Business Value

Shows customer loyalty and long-term satisfaction.

## Formula

```
Retained Customers

------------------------

Total Customers
```

## Visualization

- KPI Card

---

# 6. Average Customer Tenure

## Business Definition

Average number of months customers have remained with the company.

## Business Value

Longer tenure generally indicates higher customer satisfaction and loyalty.

## Formula

```
AVG(tenure_months)
```

## Source

```
fact_customer_snapshot
```

## Visualization

- KPI Card

---

# 7. Average Customer Lifetime Value (CLTV)

## Business Definition

Average predicted lifetime value of active customers.

## Business Value

Identifies the long-term financial contribution of customers.

## Formula

```
AVG(cltv)
```

## Source

```
fact_customer_snapshot
```

## Visualization

- KPI Card

---

# 8. Average Churn Score

## Business Definition

Average churn prediction score across all active customers.

## Business Value

Provides an early warning indicator for customer attrition.

## Formula

```
AVG(churn_score)
```

## Source

```
fact_customer_snapshot
```

## Visualization

- Gauge
- KPI Card

---

# 9. Customers at High Risk

## Business Definition

Customers with a churn score greater than or equal to 75.

## Business Value

Supports proactive customer retention campaigns.

## Formula

```
COUNT(customer_key)

WHERE churn_score >= 75
```

## Source

```
fact_customer_snapshot
```

## Visualization

- KPI Card
- Table

---

# 10. Customers by Contract Type

## Business Definition

Distribution of customers by subscription contract.

Categories include:

- Month-to-Month
- One Year
- Two Year

## Business Value

Evaluates customer commitment and contract preferences.

## Source

```
fact_customer_snapshot

+

dim_plan
```

## Visualization

- Donut Chart
- Stacked Column Chart

---

# 11. Customers by Internet Service

## Business Definition

Distribution of customers based on internet technology.

Categories include:

- Fiber Optic
- DSL
- No Internet

## Business Value

Helps analyze technology adoption.

## Source

```
fact_customer_snapshot

+

dim_plan
```

## Visualization

- Donut Chart

---

# 12. Customers by Province

## Business Definition

Number of customers within each province.

## Business Value

Supports regional business planning.

## Source

```
fact_customer_snapshot

+

dim_city
```

## Visualization

- Filled Map
- Bar Chart

---

# 13. Customers by City

## Business Definition

Customer distribution across cities.

## Business Value

Identifies major customer markets.

## Source

```
fact_customer_snapshot

+

dim_city
```

## Visualization

- Filled Map
- Horizontal Bar Chart

---

# 14. Customers by Revenue Segment

## Business Definition

Distribution of customers based on generated revenue.

Revenue Categories

- Low
- Medium
- High
- Premium

## Business Value

Supports targeted marketing and pricing strategies.

## Source

```
fact_customer_snapshot
```

## Visualization

- Donut Chart

---

# 15. Customers by Usage Segment

## Business Definition

Distribution of customers according to telecom usage.

Segments

- Light
- Moderate
- Heavy

## Business Value

Supports customer profiling and service optimization.

## Source

```
fact_customer_snapshot
```

## Visualization

- Donut Chart

---

# 16. Customers by Risk Category

## Business Definition

Distribution of customers according to churn risk.

Categories

- Low Risk
- Medium Risk
- High Risk

## Business Value

Helps prioritize customer retention efforts.

## Source

```
fact_customer_snapshot
```

## Visualization

- Stacked Bar Chart

---

# 17. Customer Acquisition Trend

## Business Definition

Monthly trend showing the number of newly acquired customers.

## Business Value

Measures customer acquisition performance over time.

## Formula

```
COUNT(new_customers)

GROUP BY Month
```

## Source

```
fact_customer_snapshot

+

dim_date
```

## Visualization

- Line Chart

---

# 18. Customer Churn Trend

## Business Definition

Monthly trend showing customer churn.

## Business Value

Monitors changes in churn over time.

## Formula

```
COUNT(churn_flag = TRUE)

GROUP BY Month
```

## Source

```
fact_customer_snapshot

+

dim_date
```

## Visualization

- Line Chart

---

# Customer Dashboard Summary

The Customer Analytics Dashboard will display:

- Total Customers
- Active Customers
- Churned Customers
- Customer Growth Rate
- Customer Retention Rate
- Average Tenure
- Average CLTV
- Average Churn Score
- High-Risk Customers
- Customer Acquisition Trend
- Customer Churn Trend
- Customers by Contract
- Customers by Internet Service
- Customers by Province
- Customers by City
- Revenue Segmentation
- Usage Segmentation
- Risk Segmentation

These KPIs provide a complete view of customer acquisition, retention, loyalty, and segmentation, enabling business users to monitor customer health and identify opportunities for growth and retention.

# Financial & Revenue KPIs

Financial and Revenue KPIs evaluate the financial health of the telecom business by measuring customer value, revenue generation, profitability indicators, and revenue trends.

Primary Source Tables:

- fact_customer_snapshot
- dim_customer
- dim_plan
- dim_city
- dim_date

---

# Financial KPIs

## 1. Total Revenue

### Business Definition

Total revenue generated during the selected reporting period.

### Business Value

Represents the company's total income from telecom services.

### Formula

```
SUM(bill_amount)
```

### Source

```
fact_customer_snapshot
```

### Refresh

Monthly

### Visualization

- KPI Card

---

## 2. Monthly Revenue

### Business Definition

Revenue generated each month.

### Formula

```
SUM(bill_amount)

GROUP BY Month
```

### Source

```
fact_customer_snapshot

+

dim_date
```

### Visualization

- Line Chart

---

## 3. Revenue Growth Rate

### Business Definition

Percentage increase or decrease in revenue compared to the previous month.

### Business Value

Measures business growth.

### Formula

```
(Current Month Revenue

-

Previous Month Revenue)

---------------------------------

Previous Month Revenue
```

### Source

```
fact_customer_snapshot
```

### Visualization

- Line Chart

---

## 4. Monthly Recurring Revenue (MRR)

### Business Definition

Expected recurring subscription revenue generated every month.

### Formula

```
SUM(monthly_charge)
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 5. Annual Recurring Revenue (ARR)

### Business Definition

Estimated yearly recurring revenue.

### Formula

```
MRR × 12
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 6. Average Revenue Per User (ARPU)

### Business Definition

Average monthly revenue generated by each active customer.

### Formula

```
Total Revenue

-------------------------

Active Customers
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 7. Average Revenue Per Paying Customer (ARPPU)

### Business Definition

Average revenue generated by customers who successfully made payments.

### Formula

```
Revenue

------------------------

Paying Customers
```

### Source

```
fact_customer_snapshot

+

fact_payment
```

### Visualization

- KPI Card

---

## 8. Average Customer Lifetime Value (CLTV)

### Business Definition

Average predicted lifetime value across all customers.

### Formula

```
AVG(CLTV)
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 9. Revenue Lost Due to Churn

### Business Definition

Estimated monthly revenue lost from customers who churned.

### Formula

```
SUM(monthly_charge)

WHERE churn_flag = TRUE
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 10. Revenue Recovery Rate

### Business Definition

Percentage of previously lost revenue recovered through retained or reactivated customers.

### Formula

```
Recovered Revenue

----------------------------

Lost Revenue
```

### Source

```
fact_customer_snapshot
```

### Visualization

- Gauge

---

# Revenue Distribution KPIs

## 11. Revenue by Province

### Business Definition

Revenue generated by each province.

### Source

```
fact_customer_snapshot

+

dim_city
```

### Visualization

- Filled Map
- Column Chart

---

## 12. Revenue by City

### Business Definition

Revenue generated within each city.

### Source

```
fact_customer_snapshot

+

dim_city
```

### Visualization

- Bar Chart
- Filled Map

---

## 13. Revenue by Contract Type

### Business Definition

Revenue contribution by subscription contract.

Categories

- Month-to-Month
- One Year
- Two Year

### Source

```
fact_customer_snapshot

+

dim_plan
```

### Visualization

- Stacked Column Chart

---

## 14. Revenue by Internet Service

### Business Definition

Revenue generated by internet technology.

Categories

- Fiber
- DSL
- No Internet

### Visualization

- Donut Chart
- Column Chart

---

## 15. Revenue by Customer Segment

### Business Definition

Revenue generated by each customer segment.

Segments

- Low Value
- Medium Value
- High Value
- Premium

### Visualization

- Treemap

---

## 16. Revenue by Usage Segment

### Business Definition

Revenue generated by customer usage behavior.

Segments

- Light
- Moderate
- Heavy

### Visualization

- Stacked Bar Chart

---

## 17. Revenue by Payment Status

### Business Definition

Revenue grouped according to payment completion.

Categories

- Paid
- Pending
- Failed

### Source

```
fact_payment
```

### Visualization

- Donut Chart

---

## 18. Revenue by Customer Tenure

### Business Definition

Revenue contribution grouped by customer tenure.

Categories

- New
- Growing
- Loyal
- VIP

### Visualization

- Horizontal Bar Chart

---

## 19. Revenue by Churn Status

### Business Definition

Comparison of revenue generated by active and churned customers.

### Visualization

- Clustered Column Chart

---

## 20. Top 10 Revenue Generating Cities

### Business Definition

Cities contributing the highest monthly revenue.

### Visualization

- Horizontal Bar Chart

---

# Profitability & Business Health KPIs

## 21. Average Monthly Bill

### Formula

```
AVG(bill_amount)
```

### Visualization

- KPI Card

---

## 22. Highest Monthly Bill

### Formula

```
MAX(bill_amount)
```

### Visualization

- KPI Card

---

## 23. Lowest Monthly Bill

### Formula

```
MIN(bill_amount)
```

### Visualization

- KPI Card

---

## 24. High Value Customers

### Business Definition

Customers whose monthly revenue falls within the top 10%.

### Formula

```
Revenue >= 90th Percentile
```

### Visualization

- Table

---

## 25. Premium Customer Percentage

### Formula

```
Premium Customers

------------------------

Total Customers
```

### Visualization

- KPI Card

---

## 26. Average Discount Amount

### Business Definition

Average monthly promotional discount offered to customers.

### Formula

```
AVG(discount_amount)
```

### Visualization

- KPI Card

---

## 27. Revenue Forecast

### Business Definition

Predicted monthly revenue generated using forecasting models.

### Source

```
Power BI Forecast

or

Python Time Series
```

### Visualization

- Forecast Line Chart

---

## Financial Dashboard Summary

The Revenue & Financial Dashboard will include:

- Total Revenue
- Monthly Revenue
- Revenue Growth Rate
- Monthly Recurring Revenue (MRR)
- Annual Recurring Revenue (ARR)
- Average Revenue Per User (ARPU)
- Average Revenue Per Paying User (ARPPU)
- Average CLTV
- Revenue Lost Due to Churn
- Revenue Recovery Rate
- Revenue by Province
- Revenue by City
- Revenue by Contract
- Revenue by Internet Service
- Revenue by Customer Segment
- Revenue by Usage Segment
- Revenue by Payment Status
- Revenue by Tenure
- Revenue by Churn Status
- Top Revenue Cities
- Average Monthly Bill
- Highest Monthly Bill
- Lowest Monthly Bill
- High Value Customers
- Premium Customer Percentage
- Average Discount
- Revenue Forecast

These KPIs provide a comprehensive financial view of the telecom business, supporting executive decision-making, profitability analysis, customer value assessment, and strategic revenue planning.

# Usage & Network KPIs

Usage and Network KPIs measure customer service consumption, telecom network quality, and infrastructure performance.

These KPIs help telecom operators understand customer behavior, optimize network resources, improve customer experience, and reduce churn caused by poor service quality.

Primary Source Tables

- fact_customer_snapshot
- dim_customer
- dim_plan
- dim_city
- dim_tower
- dim_date

---

# Usage KPIs

## 1. Total Data Usage

### Business Definition

Total internet data consumed by customers during the selected reporting period.

### Formula

```
SUM(data_usage_gb)
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 2. Average Data Usage

### Business Definition

Average monthly data consumption per customer.

### Formula

```
AVG(data_usage_gb)
```

### Visualization

- KPI Card

---

## 3. Total Voice Minutes

### Business Definition

Total voice calling minutes used.

### Formula

```
SUM(voice_minutes)
```

### Visualization

- KPI Card

---

## 4. Average Voice Minutes

### Formula

```
AVG(voice_minutes)
```

### Visualization

- KPI Card

---

## 5. Total SMS

### Formula

```
SUM(sms_count)
```

### Visualization

- KPI Card

---

## 6. Average SMS

### Formula

```
AVG(sms_count)
```

### Visualization

- KPI Card

---

## 7. Total Roaming Minutes

### Formula

```
SUM(roaming_minutes)
```

### Visualization

- KPI Card

---

## 8. Average Roaming Minutes

### Formula

```
AVG(roaming_minutes)
```

### Visualization

- KPI Card

---

## 9. Total International Minutes

### Formula

```
SUM(international_minutes)
```

### Visualization

- KPI Card

---

## 10. Average International Minutes

### Formula

```
AVG(international_minutes)
```

### Visualization

- KPI Card

---

## 11. Average Monthly Usage

### Business Definition

Combined monthly telecom usage.

### Formula

```
AVG(

data_usage_gb

+

voice_minutes

+

sms_count

)
```

### Visualization

- KPI Card

---

## 12. Heavy Usage Customers

### Business Definition

Customers within the top 10% of monthly telecom usage.

### Formula

```
Usage >= 90th Percentile
```

### Visualization

- Table

---

## 13. Light Usage Customers

### Business Definition

Customers within the bottom 25% of monthly usage.

### Visualization

- KPI Card

---

## 14. Usage by Contract Type

### Source

```
fact_customer_snapshot

+

dim_plan
```

### Visualization

- Stacked Column Chart

---

## 15. Usage by Internet Service

### Visualization

- Clustered Column Chart

---

## 16. Usage by City

### Source

```
fact_customer_snapshot

+

dim_city
```

### Visualization

- Filled Map

---

## 17. Usage by Province

### Visualization

- Filled Map

---

## 18. Usage by Customer Segment

### Visualization

- Treemap

---

## 19. Monthly Usage Trend

### Formula

```
SUM(data_usage_gb)

GROUP BY Month
```

### Visualization

- Line Chart

---

## 20. Top Data Consuming Cities

### Visualization

- Horizontal Bar Chart

---

# Network KPIs

## 21. Average Network Score

### Business Definition

Average network quality experienced by customers.

### Formula

```
AVG(network_score)
```

### Source

```
fact_customer_snapshot
```

### Visualization

- KPI Card

---

## 22. Average Signal Strength

### Formula

```
AVG(signal_strength)
```

### Visualization

- KPI Card

---

## 23. Average Latency

### Formula

```
AVG(latency_ms)
```

### Visualization

- KPI Card

---

## 24. Average Packet Loss

### Formula

```
AVG(packet_loss_percent)
```

### Visualization

- KPI Card

---

## 25. Total Downtime

### Formula

```
SUM(downtime_minutes)
```

### Visualization

- KPI Card

---

## 26. Network Availability

### Formula

```
100 -

Downtime %
```

### Visualization

- Gauge

---

## 27. Network Health Index

### Business Definition

Composite KPI measuring overall network performance.

### Formula

Weighted Average of

```
Signal Strength

Latency

Packet Loss

Downtime

Network Score
```

### Visualization

- Gauge

---

## 28. Customers with Poor Signal

### Formula

```
COUNT(customer_key)

WHERE signal_strength < Threshold
```

### Visualization

- KPI Card

---

## 29. High Latency Customers

### Formula

```
COUNT(customer_key)

WHERE latency_ms > Threshold
```

### Visualization

- KPI Card

---

## 30. High Packet Loss Customers

### Formula

```
COUNT(customer_key)

WHERE packet_loss_percent > Threshold
```

### Visualization

- KPI Card

---

## 31. Network Quality by City

### Source

```
fact_customer_snapshot

+

dim_city
```

### Visualization

- Filled Map

---

## 32. Network Quality by Province

### Visualization

- Filled Map

---

## 33. Network Quality by Contract

### Visualization

- Clustered Column Chart

---

## 34. Network Quality by Internet Service

### Visualization

- Column Chart

---

## 35. Average Tower Coverage

### Source

```
dim_tower
```

### Formula

```
AVG(range)
```

### Visualization

- KPI Card

---

## 36. Tower Distribution by Radio Technology

### Categories

- LTE

- GSM

- UMTS

- NR (5G)

### Visualization

- Donut Chart

---

## 37. Towers by Province

### Visualization

- Filled Map

---

## 38. Towers by City

### Visualization

- Filled Map

---

## 39. Tower Sample Density

### Formula

```
AVG(samples)
```

### Visualization

- Scatter Plot

---

## 40. Network Coverage Map

### Business Definition

Interactive map displaying network tower locations and coverage.

### Source

```
dim_tower
```

### Visualization

- Azure Map
- ArcGIS Map
- Filled Map

---

# Usage & Network Dashboard Summary

The Usage & Network Dashboard will include:

- Total Data Usage
- Average Data Usage
- Total Voice Minutes
- Average Voice Minutes
- Total SMS
- Average SMS
- Total Roaming Minutes
- Average Roaming Minutes
- Total International Minutes
- Average International Minutes
- Heavy Usage Customers
- Usage by Contract
- Usage by Internet Service
- Usage by City
- Usage by Province
- Monthly Usage Trend
- Top Data Consuming Cities
- Average Network Score
- Average Signal Strength
- Average Latency
- Average Packet Loss
- Total Downtime
- Network Availability
- Network Health Index
- Customers with Poor Signal
- High Latency Customers
- High Packet Loss Customers
- Network Quality by City
- Network Quality by Province
- Network Quality by Contract
- Tower Coverage
- Tower Distribution by Radio Technology
- Towers by Province
- Tower Sample Density
- Interactive Network Coverage Map

These KPIs provide a complete operational view of telecom service consumption and network performance, enabling engineering, operations, and business teams to monitor customer experience, identify infrastructure bottlenecks, and optimize service quality.

# Payment & Support KPIs

Payment and Support KPIs evaluate customer payment behavior, revenue collection efficiency, customer service quality, and operational performance.

These metrics help finance teams improve cash flow while enabling customer support teams to maintain high service standards and customer satisfaction.

Primary Source Tables

- fact_payment
- fact_support
- fact_customer_snapshot
- dim_customer
- dim_city
- dim_date

---

# Payment KPIs

## 1. Total Payments

### Business Definition

Total number of payment transactions.

### Formula

```
COUNT(payment_key)
```

### Source

```
fact_payment
```

### Visualization

- KPI Card

---

## 2. Total Payment Amount

### Formula

```
SUM(payment_amount)
```

### Visualization

- KPI Card

---

## 3. Average Payment Amount

### Formula

```
AVG(payment_amount)
```

### Visualization

- KPI Card

---

## 4. Payment Success Rate

### Formula

```
Successful Payments
-------------------
Total Payments
```

### Visualization

- Gauge

---

## 5. Failed Payment Rate

### Formula

```
Failed Payments
---------------
Total Payments
```

### Visualization

- Gauge

---

## 6. Pending Payment Rate

### Formula

```
Pending Payments
----------------
Total Payments
```

### Visualization

- KPI Card

---

## 7. Outstanding Revenue

### Formula

```
SUM(outstanding_amount)
```

### Visualization

- KPI Card

---

## 8. Late Payment Rate

### Formula

```
Late Payments
-------------
Total Payments
```

### Visualization

- Gauge

---

## 9. Average Late Payment Days

### Formula

```
AVG(late_payment_days)
```

### Visualization

- KPI Card

---

## 10. Collection Efficiency

### Business Definition

Percentage of billed revenue successfully collected.

### Formula

```
Collected Revenue
-----------------
Total Billed Revenue
```

### Visualization

- KPI Card

---

## 11. Revenue Collected by Month

### Formula

```
SUM(payment_amount)

GROUP BY Month
```

### Visualization

- Line Chart

---

## 12. Revenue Collected by City

### Visualization

- Filled Map

---

## 13. Revenue Collected by Province

### Visualization

- Filled Map

---

## 14. Payment Method Distribution

### Visualization

- Donut Chart

---

## 15. Payment Status Distribution

### Categories

- Paid
- Pending
- Failed

### Visualization

- Donut Chart

---

## 16. Top Cities with Late Payments

### Visualization

- Horizontal Bar Chart

---

## 17. High-Risk Customers

### Business Definition

Customers having repeated failed or overdue payments.

### Visualization

- Table

---

## 18. Monthly Collection Trend

### Visualization

- Line Chart

---

## 19. Average Outstanding Balance

### Formula

```
AVG(outstanding_amount)
```

### Visualization

- KPI Card

---

## 20. Payment Compliance Score

### Business Definition

Composite metric measuring customer payment discipline.

Factors include

- Payment Success
- Late Payment Days
- Outstanding Balance
- Payment Frequency

### Visualization

- KPI Card

---

# Support KPIs

## 21. Total Support Tickets

### Formula

```
COUNT(ticket_key)
```

### Source

```
fact_support
```

### Visualization

- KPI Card

---

## 22. Open Tickets

### Formula

```
COUNT(ticket_key)

WHERE ticket_status='Open'
```

### Visualization

- KPI Card

---

## 23. Closed Tickets

### Formula

```
COUNT(ticket_key)

WHERE ticket_status='Closed'
```

### Visualization

- KPI Card

---

## 24. Ticket Closure Rate

### Formula

```
Closed Tickets
--------------
Total Tickets
```

### Visualization

- Gauge

---

## 25. Average Resolution Time

### Formula

```
AVG(resolution_time_hours)
```

### Visualization

- KPI Card

---

## 26. SLA Compliance Rate

### Business Definition

Percentage of tickets resolved within the SLA target.

### Formula

```
Tickets within SLA
------------------
Total Tickets
```

### Visualization

- Gauge

---

## 27. First Contact Resolution Rate

### Formula

```
Resolved on First Contact
-------------------------
Total Tickets
```

### Visualization

- KPI Card

---

## 28. Average Tickets per Customer

### Formula

```
Total Tickets
-------------
Total Customers
```

### Visualization

- KPI Card

---

## 29. Repeat Complaint Rate

### Business Definition

Customers submitting multiple tickets for the same issue.

### Visualization

- KPI Card

---

## 30. Ticket Priority Distribution

### Categories

- Low
- Medium
- High
- Critical

### Visualization

- Donut Chart

---

## 31. Ticket Status Distribution

### Visualization

- Donut Chart

---

## 32. Complaint Category Distribution

### Visualization

- Horizontal Bar Chart

---

## 33. Tickets by City

### Visualization

- Filled Map

---

## 34. Tickets by Province

### Visualization

- Filled Map

---

## 35. Tickets by Contract Type

### Visualization

- Stacked Column Chart

---

## 36. Monthly Ticket Trend

### Visualization

- Line Chart

---

## 37. Peak Support Hours

### Business Definition

Hours generating the highest ticket volume.

### Visualization

- Column Chart

---

## 38. Customer Satisfaction Score (Synthetic)

### Formula

Average survey rating.

```
AVG(customer_satisfaction_score)
```

### Visualization

- KPI Card

---

## 39. Support Workload

### Formula

```
Tickets per Support Agent
```

### Visualization

- KPI Card

---

## 40. Escalation Rate

### Formula

```
Escalated Tickets
-----------------
Total Tickets
```

### Visualization

- Gauge

---

## 41. Average Escalation Resolution Time

### Formula

```
AVG(escalation_resolution_hours)
```

### Visualization

- KPI Card

---

## 42. Top Complaint Categories

### Visualization

- Horizontal Bar Chart

---

## 43. Customers with Multiple Complaints

### Formula

```
COUNT(customer_key)

HAVING Ticket Count > Threshold
```

### Visualization

- Table

---

## 44. Support Performance Score

### Business Definition

Composite KPI combining

- Resolution Time
- SLA Compliance
- Customer Satisfaction
- Ticket Closure Rate

### Visualization

- KPI Card

---

# Payment & Support Dashboard Summary

The Payment & Support Dashboard will include:

- Total Payments
- Total Payment Amount
- Average Payment Amount
- Payment Success Rate
- Failed Payment Rate
- Pending Payment Rate
- Outstanding Revenue
- Late Payment Rate
- Average Late Payment Days
- Collection Efficiency
- Monthly Collection Trend
- Revenue by City
- Payment Method Distribution
- Payment Status Distribution
- High-Risk Customers
- Payment Compliance Score
- Total Support Tickets
- Open Tickets
- Closed Tickets
- Ticket Closure Rate
- Average Resolution Time
- SLA Compliance Rate
- First Contact Resolution Rate
- Average Tickets per Customer
- Repeat Complaint Rate
- Ticket Priority Distribution
- Complaint Category Distribution
- Tickets by City
- Monthly Ticket Trend
- Customer Satisfaction Score
- Support Workload
- Escalation Rate
- Average Escalation Resolution Time
- Top Complaint Categories
- Customers with Multiple Complaints
- Support Performance Score

These KPIs provide a comprehensive operational view of financial collections and customer support, helping telecom organizations improve revenue recovery, optimize service quality, reduce customer churn, and enhance the overall customer experience.

# Executive Dashboard KPIs

The Executive Dashboard provides a high-level overview of the telecom business and is designed for senior management and executives.

The dashboard focuses on business growth, revenue, customer retention, operational efficiency, and network health.

## Executive KPI Cards

- Total Customers
- Active Customers
- Churned Customers
- Churn Rate
- Total Revenue
- Monthly Revenue
- Average Revenue Per User (ARPU)
- Average Customer Lifetime Value (CLTV)
- Average Customer Tenure
- Average Network Score
- Payment Success Rate
- Customer Satisfaction Score

---

## Executive Visualizations

| Visualization | Purpose |
|--------------|---------|
| KPI Cards | Overall business health |
| Monthly Revenue Trend | Revenue growth over time |
| Customer Growth Trend | Customer acquisition trend |
| Churn Trend | Customer retention monitoring |
| Revenue by Province | Geographic revenue analysis |
| Churn by Province | Regional churn analysis |
| Network Score by Province | Infrastructure performance |
| Revenue vs Churn Scatter Plot | Business relationship analysis |

---

# Customer Analytics Dashboard

Designed for Customer Success and Marketing teams.

## KPIs

- Total Customers
- Active Customers
- New Customers
- Customer Growth Rate
- Customer Retention Rate
- Average Tenure
- Average CLTV
- Customers at Risk
- Customer Segmentation
- Customer Distribution by Contract
- Customer Distribution by Internet Service
- Customer Distribution by City
- Customer Distribution by Province

---

# Revenue Dashboard

Designed for Finance and Business teams.

## KPIs

- Total Revenue
- Monthly Revenue
- Annual Revenue
- ARPU
- Average Bill Amount
- Revenue by Province
- Revenue by City
- Revenue by Contract
- Revenue by Internet Service
- Revenue Growth Rate
- Outstanding Revenue
- Collection Efficiency

---

# Churn Analytics Dashboard

Designed for Customer Retention teams.

## KPIs

- Churn Rate
- Churned Customers
- Customers at Risk
- Average Churn Score
- Churn by Contract
- Churn by Internet Service
- Churn by City
- Churn by Province
- Churn by Tenure
- Top Churn Reasons

---

# Usage Dashboard

Designed for Product Analytics teams.

## KPIs

- Total Data Usage
- Average Data Usage
- Total Voice Minutes
- Average Voice Minutes
- Total SMS
- Average SMS
- Average Roaming Minutes
- Average International Minutes
- Heavy Usage Customers
- Monthly Usage Trend
- Usage by City
- Usage by Contract
- Usage by Internet Service

---

# Payment Dashboard

Designed for Finance Operations.

## KPIs

- Total Payments
- Total Payment Amount
- Payment Success Rate
- Failed Payment Rate
- Pending Payment Rate
- Outstanding Revenue
- Average Payment Amount
- Average Late Payment Days
- Collection Efficiency
- Monthly Collection Trend
- Payment Method Distribution
- Payment Compliance Score

---

# Support Dashboard

Designed for Customer Support Operations.

## KPIs

- Total Tickets
- Open Tickets
- Closed Tickets
- Ticket Closure Rate
- Average Resolution Time
- SLA Compliance Rate
- First Contact Resolution Rate
- Customer Satisfaction Score
- Support Performance Score
- Repeat Complaint Rate
- Escalation Rate
- Top Complaint Categories
- Monthly Ticket Trend

---

# Network Dashboard

Designed for Network Operations teams.

## KPIs

- Average Network Score
- Average Signal Strength
- Average Latency
- Average Packet Loss
- Total Downtime
- Network Availability
- Network Health Index
- Customers with Poor Signal
- High Latency Customers
- High Packet Loss Customers
- Tower Coverage
- Tower Density
- Towers by Radio Technology
- Network Quality by Province
- Network Coverage Map

---

# Machine Learning KPIs

The predictive analytics module will evaluate model performance using standard machine learning metrics.

## Classification Metrics

- Accuracy
- Precision
- Recall
- F1 Score
- ROC AUC
- Log Loss
- Matthews Correlation Coefficient (MCC)

---

## Model Monitoring

- Prediction Confidence
- Feature Importance
- SHAP Feature Importance
- Precision-Recall Curve
- ROC Curve
- Confusion Matrix
- Model Drift (Future Enhancement)

---

# Refresh Strategy

| Layer | Refresh Frequency |
|---------|------------------|
| Bronze | Manual CSV Import |
| Silver | During ETL Execution |
| Gold | After Successful ETL |
| Power BI Dataset | Scheduled Refresh |
| Machine Learning Features | After Gold Refresh |

---

# KPI Ownership

| KPI Category | Business Owner |
|--------------|----------------|
| Executive | CEO / Executive Leadership |
| Customer | Customer Success |
| Revenue | Finance |
| Churn | Marketing & Retention |
| Usage | Product Analytics |
| Payments | Finance Operations |
| Support | Customer Operations |
| Network | Network Operations |
| Machine Learning | Data Science Team |

---

# Dashboard Navigation

```
Executive Dashboard
        │
        ├──────────────┐
        │              │
        ▼              ▼
Customer Dashboard   Revenue Dashboard
        │              │
        ├──────┐       │
        ▼      ▼       ▼
Usage   Churn  Payment Dashboard
        │
        ▼
Support Dashboard
        │
        ▼
Network Dashboard
        │
        ▼
Machine Learning Dashboard
```

---

# Power BI Dashboard Layout

The Power BI solution will contain the following report pages:

1. Executive Overview
2. Customer Analytics
3. Revenue Analytics
4. Churn Intelligence
5. Usage Analytics
6. Payment Analytics
7. Customer Support Analytics
8. Network Performance
9. Geographic Analysis
10. Machine Learning Insights

---

# KPI Design Principles

The KPI catalog follows these principles:

- Every KPI supports a measurable business objective.
- KPIs are calculated from the Gold Layer warehouse.
- All KPIs have clearly defined formulas.
- Monthly customer snapshots provide the primary analytical source.
- Additional fact tables support operational drill-down analysis.
- KPIs are reusable across SQL queries, Power BI dashboards, and machine learning models.
- All KPIs are traceable to documented source tables.

---

# Project Deliverables Supported by the KPI Catalog

The KPIs defined in this document support:

- PostgreSQL Data Warehouse
- SQL Analytics
- Power BI Dashboards
- Executive Reporting
- Customer Segmentation
- Churn Prediction
- Revenue Analysis
- Network Performance Monitoring
- Customer Support Analytics
- Machine Learning Feature Engineering

---

# Summary

This KPI Catalog serves as the business analytics foundation of the **Telecom Customer Analytics & Churn Intelligence Platform**.

With more than **120 enterprise-grade KPIs**, organized into executive, financial, customer, operational, network, and machine learning domains, the platform provides a comprehensive decision-support system that mirrors the analytical capabilities of modern telecom organizations.

The combination of a Kimball Star Schema, a central `fact_customer_snapshot`, operational fact tables, and Power BI dashboards enables scalable, production-inspired analytics suitable for portfolio presentation, technical interviews, and enterprise data engineering practices.