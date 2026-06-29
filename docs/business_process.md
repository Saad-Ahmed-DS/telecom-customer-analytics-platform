# Business Process

## Project

**Telecom Customer Analytics & Churn Intelligence Platform**

---

# Purpose

The Telecom Customer Analytics & Churn Intelligence Platform is designed to simulate a modern telecom company's Business Intelligence (BI) and analytics environment.

The project integrates multiple real-world datasets into a centralized PostgreSQL data warehouse to provide comprehensive insights into customer behavior, service usage, revenue generation, network performance, and customer churn.

Instead of treating churn prediction as the primary objective, this project focuses on building an end-to-end analytics platform that supports business decision-making through data engineering, SQL analytics, business intelligence dashboards, and predictive analytics.

---

# Business Objective

The primary business objective is to help telecom companies answer critical operational and strategic questions such as:

- Which customers are most likely to churn?
- Which subscription plans generate the highest revenue?
- Which customer segments are most profitable?
- Which cities experience the highest churn?
- How does network quality impact customer retention?
- Which payment behaviors indicate future churn?
- How can customer lifetime value (CLTV) be improved?

The platform enables business stakeholders to monitor key performance indicators (KPIs) and make data-driven decisions.

---

# Business Processes Modeled

The project models the complete customer lifecycle within a telecom company.

## 1. Customer Registration

A customer joins the telecom company and subscribes to one or more services.

Captured Information:

- Customer demographics
- Partner status
- Dependents
- Senior citizen status
- Geographic location

Source:
- IBM Telco Customer Churn Dataset

---

## 2. Subscription Management

Each customer subscribes to telecom services and chooses a contract type.

Examples:

- Fiber Internet
- DSL Internet
- Phone Service
- Streaming TV
- Streaming Movies

The project stores subscription-related information separately to support future scalability.

---

## 3. Monthly Service Usage

Customers consume telecom services every month.

Examples:

- Internet Data Usage
- Voice Minutes
- SMS Usage
- Roaming Usage
- International Calls

Each monthly record represents a customer's service consumption during a billing period.

---

## 4. Monthly Billing

Every billing cycle generates a bill based on customer subscriptions and usage.

Billing information includes:

- Monthly Charges
- Total Charges
- Taxes
- Discounts
- Outstanding Balance

This process supports revenue analytics and financial reporting.

---

## 5. Customer Payments

Customers pay their monthly bills using different payment methods.

Examples:

- Credit Card
- Bank Transfer
- Electronic Check
- Mailed Check

Payment history will later support payment trend analysis and churn prediction.

---

## 6. Customer Support

Customers may contact support for various issues.

Examples:

- Network Problems
- Billing Issues
- Service Requests
- Technical Support

Support data enables operational analytics and customer satisfaction analysis.

---

## 7. Network Monitoring

Network infrastructure is monitored using tower information and quality metrics.

Examples:

- Signal Strength
- Tower Coverage
- Latency
- Downtime
- Radio Technology

The objective is to analyze how network performance influences customer experience.

---

## 8. Customer Churn

Some customers discontinue their telecom services.

The project analyzes churn using:

- Customer Profile
- Subscription History
- Service Usage
- Payment History
- Support Activity
- Network Quality

This enables predictive analytics and customer retention strategies.

---

# Business Stakeholders

The platform is designed to support the following stakeholders:

| Stakeholder | Business Need |
|-------------|---------------|
| Executive Management | Overall business performance |
| Finance Team | Revenue and billing analytics |
| Customer Success Team | Customer retention |
| Marketing Team | Customer segmentation |
| Network Operations Team | Network performance monitoring |
| Technical Support Team | Support workload analysis |
| Data Analytics Team | Dashboard creation and predictive analytics |

---

# Business KPIs

The platform will measure several business KPIs.

Customer KPIs

- Total Customers
- Active Customers
- Churn Rate
- Customer Lifetime Value (CLTV)

Revenue KPIs

- Monthly Revenue
- Average Revenue Per User (ARPU)
- Outstanding Revenue

Usage KPIs

- Average Data Usage
- Average Voice Minutes
- Average SMS Usage

Support KPIs

- Number of Tickets
- Average Resolution Time
- Open vs Closed Tickets

Network KPIs

- Average Signal Strength
- Tower Availability
- Network Downtime

---

# Scope

Included

- Customer Analytics
- Churn Analysis
- Revenue Analytics
- Usage Analytics
- Payment Analytics
- Network Analytics
- Power BI Dashboards
- PostgreSQL Data Warehouse
- SQL Reporting
- Machine Learning

Not Included

- Real-time Streaming
- Live Customer Transactions
- Real Telecom APIs
- Authentication Systems
- CRM Integration
- Billing System Integration

---

# Expected Outcome

The final platform will simulate an enterprise telecom analytics environment where multiple datasets are integrated into a centralized PostgreSQL data warehouse.

The warehouse will support advanced SQL queries, Power BI dashboards, business reporting, and churn prediction models, demonstrating skills in data engineering, business intelligence, analytics, and machine learning.