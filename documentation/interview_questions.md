# Technical & Business Interview Preparation Guide

This document contains **25 interview questions and answers** specifically tailored to the **Sales & Customer Performance Analytics | SQL** project.

---

## Part 1: Database Design & Architecture Questions

### Q1: Why did you choose MySQL 8+ for this project?
**Answer:** MySQL 8+ introduces native support for window functions (`RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, `SUM() OVER()`), Common Table Expressions (CTEs), and improved query optimizer hints. These capabilities allowed me to write clean, modular, high-performance analytical queries without needing complex nested subqueries or temporary staging tables.

### Q2: Walk me through your database schema design. Why is it structured this way?
**Answer:** The database follows a normalized Third Normal Form (3NF) dimensional structure:
- **Fact Table:** `sales_transactions` stores 105,000 transaction events with granular metrics (`order_qty`, `unit_price`, `unit_cost`, `sales_amount`, `cost_amount`, `profit_amount`).
- **Dimension Tables:** `customers`, `products`, and `markets` store descriptive attributes.
- **Target Fact Table:** `targets` stores monthly sales quotas by market.
Foreign keys (`FK`) enforce referential integrity between dimensions and sales. Indexes on `order_date`, `customer_code`, `product_code`, and composite `(market_code, order_date)` optimize filter and aggregation performance.

### Q3: How did you handle primary and foreign key constraints?
**Answer:** Primary keys (`PK`) were defined on unique codes (e.g., `market_code`, `product_code`, `customer_code`, `transaction_id`). Foreign key constraints use `ON DELETE RESTRICT ON UPDATE CASCADE` to prevent orphan transactions if dimension keys change while ensuring master data updates automatically propagate down to fact tables.

### Q4: Why did you create analytical views like `vw_target_performance`?
**Answer:** Analytical views abstract complex multi-table JOINs and `COALESCE` logic away from end users and BI dashboards. `vw_target_performance` pre-calculates actual sales, target sales, variance, and achievement % per market and month, allowing BI analysts to query `SELECT * FROM vw_target_performance` without rewriting 30 lines of SQL logic every time.

---

## Part 2: Data Quality & Ingestion Questions

### Q5: How did you validate data quality before performing analysis?
**Answer:** In `03_data_quality.sql`, I executed a suite of auditing queries checking:
1. **Row Counts:** Verified exact row counts across all 5 tables.
2. **Null Checks:** Audited critical foreign key fields and monetary amounts for missing values using `SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END)`.
3. **Duplicates:** Audited `transaction_id` grouping to confirm zero duplicate primary key entries.
4. **Referential Integrity:** Ran `LEFT JOIN` queries where dimension table `PK IS NULL` to ensure zero orphan foreign keys.
5. **Numerical Sanity:** Verified that quantities and prices were strictly positive (`> 0`).

### Q6: How would you handle a large CSV data load in MySQL if `local_infile` is disabled?
**Answer:** If `local_infile` is restricted due to MySQL server security policies, alternative methods include:
1. **MySQL Workbench Table Data Import Wizard:** Graphical CSV batch importer.
2. **Command-line Utility:** Executing `mysql --local-infile=1` with explicit client authorization.
3. **Python Ingestion Script:** Using `pandas` and `sqlalchemy` / `mysql-connector-python` to chunk data into 5,000-row batch inserts via Python.

---

## Part 3: Analytical SQL & Window Function Questions

### Q7: Why did you use `DENSE_RANK()` instead of `RANK()` or `ROW_NUMBER()` for customer ranking?
**Answer:** `DENSE_RANK()` is preferred for revenue rankings because if two customers have identical total sales revenue, they receive the same rank number, and the next rank number is consecutive (e.g., 1, 2, 2, 3). `RANK()` would skip the next rank (e.g., 1, 2, 2, 4), and `ROW_NUMBER()` would arbitrarily assign one customer above the other without a tie-breaker.

### Q8: How did you calculate Month-over-Month (MoM) revenue growth using `LAG()`?
**Answer:** First, I built a CTE `monthly_revenue` to sum `sales_amount` grouped by `DATE_FORMAT(order_date, '%Y-%m')`. Then I used `LAG(monthly_revenue, 1) OVER (ORDER BY year_month)` to fetch the previous month's revenue. MoM growth % was computed as `((current_rev - prev_rev) / prev_rev) * 100`, using `NULLIF()` to guard against divide-by-zero errors.

### Q9: How did you write a query to select the Top 3 products per category?
**Answer:** I used a CTE that joined `products` and `sales_transactions`, grouped by `category` and `product_code`, and calculated `DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(sales_amount) DESC) AS rank_in_category`. In the outer query, I filtered `WHERE rank_in_category <= 3`.

### Q10: What is the difference between `SUM(sales_amount)` and `SUM(sales_amount) OVER (ORDER BY year_month)`?
**Answer:** `SUM(sales_amount)` with `GROUP BY` returns a single collapsed total row per group. `SUM(sales_amount) OVER (ORDER BY year_month)` is a window aggregate that computes a cumulative running total line-by-line across ordered months without collapsing the detail rows.

### Q11: How did you safely handle potential divide-by-zero errors in target achievement calculations?
**Answer:** I wrapped all target denominator values in `NULLIF(target_sales, 0)`. If `target_sales` is 0 or NULL, `NULLIF()` converts it to `NULL`, causing the division result to return `NULL` cleanly rather than throwing a MySQL runtime error (`ERROR 1365: Division by 0`).

---

## Part 4: Business Insights & Strategic Analysis Questions

### Q12: What were the overall revenue and profit metrics found in this analysis?
**Answer:** Over 105,000 transactions between 2023 and 2025, total revenue was **$167,693,927.24**, total cost was **$101,052,063.00**, and total gross profit was **$66,641,864.24**, maintaining a consistent gross margin of **39.74%**.

### Q13: What was the main takeaway from your Product Category analysis?
**Answer:** **Laptops & Desktops** generated the highest top-line revenue ($57.43M; 34.24% share) but had the lowest gross margin (29.22%). **Peripherals & Accessories** had the highest gross margin (49.31%), and **Storage Solutions** delivered $40.11M with a strong 44.75% gross margin. This proves that while laptops open customer accounts, accessories and storage drive company profitability.

### Q14: How did markets perform relative to their sales targets?
**Answer:** The company missed its global sales target of $208.50M by -$40.80M (80.43% overall achievement rate). While **North America West** achieved 92.40% of its target, expansion markets like **APAC Japan** (48.55%), **Middle East Dubai** (35.05%), and **LATAM Brazil** (35.02%) missed targets significantly due to overoptimistic quota allocations.

### Q15: What recommendations did you propose for top-performing customers?
**Answer:** I recommended creating a **Platinum VIP Retention Program** for the top 20 corporate accounts (which generate 68% of sales). Key features include assigned Key Account Managers, annual SLAs, quarterly business reviews, and a 2% volume rebate for exceeding $2M annual spend.

### Q16: How did you identify products with declining year-over-year performance?
**Answer:** Using conditional aggregation `SUM(CASE WHEN YEAR(order_date) = 2024 THEN sales_amount ELSE 0 END)`, I built a side-by-side comparison of 2024 vs 2025 revenue per SKU, computing `yoy_growth_pct` and filtering for SKUs with negative growth trajectories.

### Q17: What is Pareto 80/20 analysis, and how did you implement it in SQL?
**Answer:** Pareto analysis identifies the minority of inputs that drive the majority of outcomes. In `09_advanced_analysis.sql`, I used a window function `SUM(revenue) OVER (ORDER BY revenue DESC)` to compute the cumulative running revenue of customers, dividing it by total company revenue to tag accounts that make up the first 80% of total revenue.

---

## Part 5: SQL Best Practices & Optimization

### Q18: What SQL formatting and coding standards did you follow?
**Answer:** I adhered to standard SQL conventions:
- Upper-case SQL keywords (`SELECT`, `FROM`, `WHERE`, `GROUP BY`).
- Lower-case column and table names.
- Explicit table aliases (`s` for sales, `c` for customers, `m` for markets).
- Avoiding `SELECT *` in production queries to minimize I/O overhead.
- Clear block comments explaining the business intent of every query.

### Q19: How did indexing improve query performance in your database?
**Answer:** Adding indexes on `order_date` accelerated date-range filtering, while composite indexes like `(market_code, order_date)` allowed MySQL to perform index scans for market monthly trend queries without executing full table scans across 105,000 rows.

### Q20: When would you use a CTE vs a Subquery or Temporary Table?
**Answer:** CTEs (`WITH` clauses) are preferred when breaking down multi-step transformations into readable, self-documenting blocks or when referencing the same intermediate result set multiple times. Subqueries are used for simple inline filtering (e.g., `WHERE revenue > (SELECT AVG(...)`). Temporary tables are useful when caching large intermediate datasets across multiple separate query steps.

### Q21: What is the business risk of ignoring target status variances?
**Answer:** Ignoring negative target variances leads to misallocated sales commissions, unachievable sales representative quotas, excess inventory build-up in slow regions, and inaccurate revenue projections in executive financial planning.

### Q22: How would you scale this database if transaction volume grew to 50 million rows?
**Answer:** To scale to 50M rows:
1. **Partitioning:** Range-partition `sales_transactions` by `YEAR(order_date)`.
2. **Summary Summary Tables / Materialized Views:** Pre-aggregate daily/monthly totals in persistent summary tables updated via scheduled cron triggers.
3. **Columnar Engines / Data Warehouse:** Migrate historical transaction archives to MySQL HeatWave, ClickHouse, or Snowflake for analytical OLAP querying.

### Q23: What was the most technically complex query you wrote in this project?
**Answer:** Query 1 in `09_advanced_analysis.sql`, which combined a CTE for monthly aggregations with multiple window functions: `LAG()` for prior month revenue, `LEAD()` for next month revenue, `SUM() OVER()` for cumulative running total, and `AVG() OVER(ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` for a rolling 3-month moving average.

### Q24: How does this project demonstrate readiness for a Data Analyst role?
**Answer:** It demonstrates end-to-end technical competency: schema design, SQL data cleaning, advanced querying (CTEs, window functions), data quality auditing, empirical business insight extraction, executive storytelling, and practical recommendations.

### Q25: How would you present these SQL results to non-technical business stakeholders?
**Answer:** Rather than showing raw SQL output tables, I translate query results into an executive presentation format: starting with high-level KPI cards ($167.7M revenue, 39.7% margin), presenting visual trend charts for monthly sales, and highlighting clear action items (e.g., "Recalibrate LATAM target quotas" or "Bundle laptop sales with accessories").
