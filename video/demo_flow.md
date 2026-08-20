# Demo Flow & Screen Execution Guide

This document outlines the step-by-step visual demo flow for recording the portfolio case study video.

---

## Screen-by-Screen Execution Plan

### Scene 1: Introduction & GitHub Repository Overview
- **Duration:** 00:00 – 00:50 (50 seconds)
- **Active Window:** Web Browser on GitHub Repository Page (`README.md`).
- **Visual Focus:** Scroll down from repository title to Project Architecture diagram and Key Metrics summary.
- **Action:** Highlight total revenue ($167.69M), transaction count (105,000), and technology stack (MySQL 8+).

---

### Scene 2: Dataset & Database Schema
- **Duration:** 00:50 – 02:00 (70 seconds)
- **Active Window:** Browser on `documentation/data_dictionary.md` -> Switch to SQL Editor (`sql/01_database_schema.sql`).
- **Visual Focus:** Mermaid ER Diagram showing 5 entity relationships (`markets`, `customers`, `products`, `targets`, `sales_transactions`).
- **Action:** Point out Primary Keys, Foreign Keys, index creation (`idx_sales_mkt_date`), and analytical views.

---

### Scene 3: Sales Performance Execution
- **Duration:** 02:00 – 03:00 (60 seconds)
- **Active Window:** SQL Query Editor (`sql/04_sales_analysis.sql`).
- **Query to Execute:**
  ```sql
  SELECT 
      COUNT(transaction_id) AS total_transactions,
      SUM(order_qty) AS total_quantity_sold,
      ROUND(SUM(sales_amount), 2) AS total_revenue,
      ROUND(SUM(profit_amount), 2) AS gross_profit,
      ROUND((SUM(profit_amount) / NULLIF(SUM(sales_amount), 0)) * 100, 2) AS gross_margin_pct
  FROM sales_transactions;
  ```
- **Result to Highlight:** Total Revenue = $167,693,927.24 | Gross Profit = $66,641,864.24 | Margin = 39.74%.
- **Secondary Action:** Highlight MoM growth query using `LAG()`.

---

### Scene 4: Customer & Product Breakdown
- **Duration:** 03:00 – 04:00 (60 seconds)
- **Active Window:** SQL Query Editor (`sql/05_customer_analysis.sql` & `sql/06_product_analysis.sql`).
- **Query to Execute:**
  ```sql
  -- Category Contribution Query
  SELECT 
      p.category,
      ROUND(SUM(s.sales_amount), 2) AS category_revenue,
      ROUND(SUM(s.profit_amount), 2) AS category_profit,
      ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
  FROM sales_transactions s
  JOIN products p ON s.product_code = p.product_code
  GROUP BY p.category
  ORDER BY category_revenue DESC;
  ```
- **Result to Highlight:** Laptops revenue ($57.43M; 29.22% GM) vs. Peripherals margin (49.31% GM) & Storage profit ($40.11M revenue; 44.75% GM).

---

### Scene 5: Target vs. Actual Variance
- **Duration:** 04:00 – 05:00 (60 seconds)
- **Active Window:** SQL Query Editor (`sql/08_target_analysis.sql`).
- **Query to Execute:**
  ```sql
  SELECT 
      m.market_name,
      t.target_sales,
      a.actual_sales,
      ROUND(a.actual_sales - t.target_sales, 2) AS sales_variance,
      ROUND((a.actual_sales / t.target_sales) * 100, 2) AS achievement_pct,
      CASE WHEN a.actual_sales >= t.target_sales THEN 'Target Achieved' ELSE 'Target Missed' END AS status
  FROM markets m
  JOIN targets_summary t ON m.market_code = t.market_code
  JOIN actuals_summary a ON m.market_code = a.market_code
  ORDER BY actual_sales DESC;
  ```
- **Result to Highlight:** North America West (92.40% achievement) vs LATAM Brazil (35.02% achievement) and total shortfall (-$40.80M).

---

### Scene 6: Advanced SQL Patterns (CTEs & Window Functions)
- **Duration:** 05:00 – 05:45 (45 seconds)
- **Active Window:** Code Editor (`sql/09_advanced_analysis.sql`).
- **Visual Focus:** Highlight multi-step CTE structure, `DENSE_RANK() OVER (PARTITION BY category)`, and Pareto 80/20 window running totals.

---

### Scene 7: Business Insights & Strategic Recommendations
- **Duration:** 05:45 – 06:30 (45 seconds)
- **Active Window:** Web Browser on `documentation/business_recommendations.md`.
- **Visual Focus:** Action Matrix table showing P0/P1 strategic initiatives.

---

### Scene 8: Repository Structure & Closing
- **Duration:** 06:30 – 07:30 (60 seconds)
- **Active Window:** GitHub Repository main page.
- **Action:** Show clean directory layout (`sql/`, `documentation/`, `video/`, `data/`), invite questions, and conclude video.
