# RDAMP-Dimensional-Model-Tableau
# ACE Superstore Data Analytics Project

## Project Overview

### Task Objective

Following the foundational analysis completed in Task 1, Ace Superstore aims to transition its cleaned dataset into a query-optimized reporting system. This task includes two primary responsibilities:

1. Design and implement a star schema using SQL.
2. Create SQL views from the schema and connect them to a business intelligence tool to produce advanced interactive dashboards.

Dimensional modeling best practices were applied to simulate a real-world analytics workflow. The schema and reporting layer are structured to support usability, scalability, and strategic insight across multiple business domains.

### Business Impact

This solution transforms fragmented sales data into a centralized reporting model optimized for enterprise use. By structuring the data for analysis and enabling visual reporting, it empowers business users to evaluate performance across time periods, channels, products, and regions.

---

## Dimensional Schema Overview

The star schema consists of a single fact table—`fact_sales`—at the center, surrounded by five dimension tables:

- `dim_product`
- `dim_customer`
- `dim_order_mode`
- `dim_date`
- (Staging tables are used for preprocessing prior to insertion.)

The schema was designed using SQL in PostgreSQL and supports multi-angle analysis such as product trends, regional performance, customer behavior, and channel profitability.

![ACE Superstore Star Schema](./ace_star_schema.png)

---

## Table Descriptions

### Fact Table

- **fact_sales**: Contains transactional metrics and foreign keys that link each sale to dimensions of time, product, customer, and channel.

### Dimension Tables

- **dim_product**: Includes product category, sub-category, and name.
- **dim_customer**: Captures customer location attributes and business segment classification.
- **dim_order_mode**: Describes the sales channel (e.g., Online or In-Store).
- **dim_date**: Provides derived temporal values including month, quarter, and year from the order date.

---

## SQL Setup Instructions

1. Install PostgreSQL and open a SQL environment.
2. Run the `build_schema.sql` script to create dimension and fact tables.
3. Use `\copy` statements to import data from cleaned CSV files:
   - `dim_product.csv`
   - `dim_customer.csv`
   - `dim_order_mode.csv`
   - `dim_date.csv` (via staging table)
   - `fact_sales.csv` (via staging table)
4. Execute surrogate key logic for `dim_date`.
5. Insert clean and validated data into `fact_sales` using joins with `dim_date` and referential integrity checks.

---

## Business Intelligence Connection

### Tableau Public (MacOS Workflow)

Due to macOS compatibility constraints, Power BI could not be used in this project. Additionally, the lack of access to Tableau Desktop on the current system required the use of **Tableau Public** as the primary visualization tool.

Key workflow adjustments:

- CSV outputs from PostgreSQL were manually downloaded and uploaded to Tableau Public.
- Dashboards were built from static data instead of live connections.
- Published dashboards are interactive and hosted on Tableau Public for accessible analysis.

---

## Dashboard Screenshots

The screenshot below display the dashboard view used for analysis.

(tableau/Elena Losavio_Ace_Dasboard.png)

---

## Repository Structure
├── build_schema.sql ├── reusable_queries.sql ├── ace_star_schema.png ├── README.md  ├── /data │ ├── dim_product.csv │ ├── dim_customer.csv │ ├── dim_order_mode.csv │ ├── dim_date.csv │ └── fact_sales.csv ├── /screenshots │ ├── product_seasonality.png │ ├── discount_impact.png │ ├── customer_patterns.png │ ├── channel_margin.png │ └── region_rankings.png
