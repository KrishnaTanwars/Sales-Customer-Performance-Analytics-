# Sales & Customer Performance Analytics | SQL

[![Database](https://img.shields.io/badge/Database-MySQL%208.0%2B-blue?style=flat-square&logo=mysql)](https://www.mysql.com/)
[![SQL Dialect](https://img.shields.io/badge/SQL-ANSI%20%2F%20MySQL%208%2B-orange?style=flat-square)](https://dev.mysql.com/doc/refman/8.0/en/)
[![Data Size](https://img.shields.io/badge/Transactions-105%2C000%20Rows-green?style=flat-square)](#dataset)
[![License](https://img.shields.io/badge/License-MIT-purple?style=flat-square)](LICENSE)

An end-to-end, production-quality **SQL Analytics Portfolio Project** built using **MySQL 8+**. This project transforms raw transaction logs into actionable business intelligence across **105,000 sales transactions** totaling **$167.69M in revenue** between 2023 and 2025 across 10 global markets, 150 corporate accounts, and 50 technology products.

---

## 📌 Project Overview

In enterprise technology distribution, revenue growth without profit optimization can lead to operational inefficiency. This project establishes a robust relational database schema to evaluate:
- **Sales Velocity & Margins:** Gross profit performance, seasonality, MoM revenue growth, and cumulative trends.
- **Customer Account Value:** Order frequency, Average Order Value (AOV), revenue concentration (Pareto 80/20 rule), and customer value tiering.
- **Product Portfolio Performance:** Category contribution %, high-margin attach categories vs. high-volume door-openers, SKU profit rankings, and YoY product performance shifts.
- **Market & Target Variance:** Regional sales performance vs. corporate sales targets, achievement status, and negative variance analysis across international markets.

---

## 🎯 Objectives

1. **Database Architecture:** Design and implement a Third Normal Form (3NF) relational database schema with Primary Keys (`PK`), Foreign Keys (`FK`), constraints, and index optimizations in MySQL 8+.
2. **Data Pipeline & Quality Assurance:** Ingest datasets cleanly and execute automated SQL auditing scripts to verify data integrity, zero duplicate orders, zero orphan foreign keys, and numeric sanity.
3. **Advanced SQL Analysis:** Solve 25+ structured commercial business questions using multi-step CTEs, window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, `SUM/AVG OVER`), and subqueries.
4. **Empirical Business Insights:** Extract findings based strictly on database execution metrics and deliver strategic, actionable recommendations for executive leadership.

---

## 📊 Dataset Overview

*Note: Initial workspace inspection showed an empty repository. Per project guidelines, a realistic synthetic dataset containing **105,000 transaction records** spanning 2023 to 2025 was generated via Python (`scripts/generate_data.py`) and stored in `data/raw/`.*

| Entity | File Path | Record Count | Description | Primary Key |
| :--- | :--- | :--- | :--- | :--- |
| **`markets`** | `data/raw/markets.csv` | 10 rows | Global markets across 4 geographical zones | `market_code` |
| **`customers`** | `data/raw/customers.csv` | 150 rows | B2B & retail accounts across 4 channel types | `customer_code` |
| **`products`** | `data/raw/products.csv` | 50 rows | Hardware catalog items across 5 categories | `product_code` |
| **`targets`** | `data/raw/targets.csv` | 360 rows | Monthly market sales quotas (2023–2025) | Composite `(market_code, target_year, target_month)` |
| **`sales_transactions`** | `data/raw/sales_transactions.csv` | 105,000 rows | Fact table of sales order line items | `transaction_id` |

---

## 🗄️ Database Schema & Data Model

```mermaid
erdiagram
    markets ||--o{ customers : "locates in"
    markets ||--o{ targets : "has monthly target"
    markets ||--o{ sales_transactions : "conducted in"
    customers ||--o{ sales_transactions : "places order"
    products ||--o{ sales_transactions : "purchased in"

    markets {
        varchar market_code PK
        varchar market_name UK
        varchar zone
        varchar region
    }

    customers {
        varchar customer_code PK
        varchar customer_name
        varchar customer_type
        varchar market_code FK
    }

    products {
        varchar product_code PK
        varchar product_name
        varchar category
        varchar sub_category
        decimal unit_cost
        decimal unit_price
    }

    targets {
        varchar market_code PK,FK
        int target_year PK
        int target_month PK
        decimal target_sales
    }

    sales_transactions {
        varchar transaction_id PK
        date order_date
        varchar customer_code FK
        varchar product_code FK
        varchar market_code FK
        int order_qty
        decimal unit_price
        decimal unit_cost
        decimal discount_pct
        decimal sales_amount
        decimal cost_amount
        decimal profit_amount
    }
```

---

## 🛠️ SQL Techniques & Skills Demonstrated

- **Database Engineering:** `CREATE DATABASE`, `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `CHECK` constraints, composite indexes (`idx_sales_mkt_date`), and analytical `CREATE VIEW` objects.
- **Aggregations & Grouping:** Multi-dimensional aggregation using `GROUP BY`, `HAVING`, `SUM()`, `AVG()`, `COUNT()`, and `NULLIF()` for divide-by-zero protection.
- **Common Table Expressions (CTEs):** Multi-stage readability CTEs replacing nested subqueries.
- **Window Functions:**
  - **Ranking:** `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `NTILE()`
  - **Navigation:** `LAG()`, `LEAD()` for MoM revenue change and growth % calculation
  - **Framing & Aggregations:** `SUM() OVER(ORDER BY ...)` for running totals; `AVG() OVER(ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` for rolling moving averages.
- **Conditional Logic:** `CASE WHEN` statements for market target status (`Target Achieved` vs `Target Missed`), customer tiering (Platinum to Bronze), and Pareto classification.
- **Analytical Views:** `vw_monthly_sales`, `vw_customer_performance`, `vw_product_performance`, `vw_market_performance`, `vw_target_performance`.

---

## 📈 Key Findings & Executive Insights

### 1. Overall Company Performance
- **Total Revenue:** **$167,693,927.24** across 105,000 orders.
- **Gross Profit:** **$66,641,864.24** with an overall Gross Margin of **39.74%**.
- **Yearly Trajectory:** Highly consistent run-rates ($55.37M in 2023, $56.56M in 2024, $55.77M in 2025) maintaining stable ~39.8% gross margin.

### 2. Category Profitability Discrepancy
- **High Volume / Lower Margin Door-Opener:** **Laptops & Desktops** leads total revenue at **$57.43M** (34.24% of company revenue) but yields the lowest gross margin at **29.22%**.
- **Profitability Engines:** **Storage Solutions** generates **$40.11M** (23.92% revenue share) at a **44.75% GM**, and **Peripherals & Accessories** delivers the highest gross margin at **49.31%**.
- **Top SKU Superstars:** **RAID Storage Expansion Array (PROD_037)** generated **$20.01M** in revenue and **$8.40M** in profit, making it the single most profitable item in the catalog.

### 3. Customer Account Concentration (Pareto 80/20)
- **Top Customer:** Vanguard Digital #63 generated **$2,255,618.69** in revenue ($889K profit).
- **Channel Impact:** Corporate Resellers and Wholesale Distributors account for **68%** of total enterprise sales.

### 4. Global Target Shortfall & Quota Variance
- **Global Quota Gap:** Total sales target was **$208.50M** vs. **$167.69M** actuals—a negative variance of **-$40.80M** (80.43% overall achievement rate).
- **Regional Variance:** **North America West** achieved **92.40%** of target ($27.62M actuals), whereas **APAC Japan** achieved only **48.55%** ($11.51M actuals vs $23.70M target) and **LATAM Brazil** achieved only **35.02%** ($4.85M actuals vs $13.84M target).

---

## 💡 Strategic Business Recommendations

1. **Protect VIP Accounts:** Implement a Platinum Key Account Program with annual SLAs and volume rebates for the top 20 accounts driving 68% of sales.
2. **Drive Cross-Sell Attach Rates:** Bundle low-margin laptop hardware (29.22% GM) with high-margin storage (44.75% GM) and accessories (49.31% GM).
3. **Recalibrate Regional Quotas:** Lower 2026 sales quotas in LATAM Brazil, Middle East Dubai, and APAC Japan by 35–45% to align targets with realistic addressable demand.
4. **Buffer Key SKUs:** Maintain 45-day safety stock buffer for top profit products (RAID Expansion Array PROD_037 & Server Node PROD_024).
5. **Restructure International Operations:** Pivot underperforming sales offices in LATAM and Middle East into a Two-Tier Master Distributor Model to reduce fixed operational overhead.

---

## 💻 Example SQL Queries

### 1. Actual vs. Target Performance & Status (MySQL 8+)
```sql
SELECT 
    m.market_code,
    m.market_name,
    m.zone,
    t.target_sales,
    COALESCE(a.actual_sales, 0.00) AS actual_sales,
    ROUND(COALESCE(a.actual_sales, 0.00) - t.target_sales, 2) AS sales_variance,
    ROUND((COALESCE(a.actual_sales, 0.00) / NULLIF(t.target_sales, 0)) * 100, 2) AS achievement_percentage,
    CASE 
        WHEN COALESCE(a.actual_sales, 0.00) >= t.target_sales THEN 'Target Achieved'
        ELSE 'Target Missed'
    END AS status
FROM markets m
JOIN (SELECT market_code, ROUND(SUM(target_sales), 2) AS target_sales FROM targets GROUP BY market_code) t ON m.market_code = t.market_code
LEFT JOIN (SELECT market_code, ROUND(SUM(sales_amount), 2) AS actual_sales FROM sales_transactions GROUP BY market_code) a ON m.market_code = a.market_code
ORDER BY actual_sales DESC;
```

### 2. Top 3 Products Per Category Using `DENSE_RANK()`
```sql
WITH ranked_products AS (
    SELECT 
        p.category,
        p.product_code,
        p.product_name,
        ROUND(SUM(s.sales_amount), 2) AS product_revenue,
        ROUND(SUM(s.profit_amount), 2) AS product_profit,
        DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(s.sales_amount) DESC) AS rank_in_category
    FROM sales_transactions s
    JOIN products p ON s.product_code = p.product_code
    GROUP BY p.category, p.product_code, p.product_name
)
SELECT * FROM ranked_products WHERE rank_in_category <= 3 ORDER BY category, rank_in_category;
```

---

## 📁 Project Structure

```
sales-customer-performance-sql/
├── README.md
├── LICENSE
├── .gitignore
├── 10_business_insights.md
├── 11_business_recommendations.md
├── data/
│   ├── raw/
│   │   ├── markets.csv
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   ├── targets.csv
│   │   └── sales_transactions.csv
│   └── processed/
├── sql/
│   ├── 01_database_schema.sql
│   ├── 02_data_loading.sql
│   ├── 03_data_quality.sql
│   ├── 04_sales_analysis.sql
│   ├── 05_customer_analysis.sql
│   ├── 06_product_analysis.sql
│   ├── 07_market_analysis.sql
│   ├── 08_target_analysis.sql
│   └── 09_advanced_analysis.sql
├── documentation/
│   ├── data_dictionary.md
│   ├── business_questions.md
│   ├── business_insights.md
│   ├── business_recommendations.md
│   ├── resume_content.md
│   ├── project_description.md
│   └── interview_questions.md
├── screenshots/
│   └── README.md
├── video/
│   ├── screen_recording_script.md
│   ├── recording_checklist.md
│   └── demo_flow.md
└── scripts/
    ├── generate_data.py
    └── test_queries.py
```

---

## 🚀 How to Run Locally

### Prerequisites
- MySQL Server 8.0+ installed and running.
- MySQL Workbench, DBeaver, or command line MySQL client.
- Python 3.10+ (for synthetic data regeneration or automated query testing).

### Execution Steps

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/KrishnaTanwars/Sales-Customer-Performance-Analytics-.git
   cd Sales-Customer-Performance-Analytics-
   ```

2. **Generate / Regenerate Data (Optional):**
   ```bash
   python scripts/generate_data.py
   ```

3. **Build Database & Schema:**
   Open MySQL Workbench / DBeaver or run via CLI:
   ```bash
   mysql -u root -p < sql/01_database_schema.sql
   ```

4. **Load CSV Data:**
   Enable `local_infile` and execute loading script:
   ```sql
   SET GLOBAL local_infile = 1;
   ```
   ```bash
   mysql --local-infile=1 -u root -p sales_analytics_db < sql/02_data_loading.sql
   ```

5. **Run Automated Test Runner (Python Validation):**
   ```bash
   python scripts/test_queries.py
   ```

6. **Execute Analytical SQL Scripts:**
   Run scripts `03_data_quality.sql` through `09_advanced_analysis.sql` sequentially in your SQL editor.

---

## 🖼️ Screenshots & Video Presentation

- **Screenshots Guidelines:** Detailed in [`screenshots/README.md`](screenshots/README.md).
- **Video Screen Recording Script (5-8 min):** Detailed in [`video/screen_recording_script.md`](video/screen_recording_script.md).
- **Demo Flow Guide:** Detailed in [`video/demo_flow.md`](video/demo_flow.md).

---

## 📜 Resume & Portfolio Highlights

Ready-to-use resume bullets, skills list, and project metrics are available in [`documentation/resume_content.md`](documentation/resume_content.md) and [`documentation/interview_questions.md`](documentation/interview_questions.md).

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
