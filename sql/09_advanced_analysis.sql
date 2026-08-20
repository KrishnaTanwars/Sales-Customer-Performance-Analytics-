-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 09_advanced_analysis.sql
-- Description: Advanced SQL patterns demonstrating CTEs, Window Functions 
--              (RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD, SUM/AVG OVER), 
--              Subqueries, Cumulative Totals, and Pareto Analysis.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- 1. ADVANCED WINDOW FUNCTIONS & MULTI-STEP CTE:
--    MoM Sales Growth with Prior/Next Month Lead/Lag & Moving Averages
-- -----------------------------------------------------------------------------
WITH monthly_summary AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS year_month,
        ROUND(SUM(sales_amount), 2) AS monthly_revenue,
        ROUND(SUM(profit_amount), 2) AS monthly_profit
    FROM sales_transactions
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
lag_lead_calc AS (
    SELECT 
        year_month,
        monthly_revenue,
        LAG(monthly_revenue, 1) OVER (ORDER BY year_month) AS prev_month_rev,
        LEAD(monthly_revenue, 1) OVER (ORDER BY year_month) AS next_month_rev,
        SUM(monthly_revenue) OVER (ORDER BY year_month) AS running_total_revenue,
        AVG(monthly_revenue) OVER (ORDER BY year_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3m_avg_revenue
    FROM monthly_summary
)
SELECT 
    year_month,
    monthly_revenue,
    prev_month_rev,
    ROUND(monthly_revenue - prev_month_rev, 2) AS mom_dollar_change,
    ROUND(((monthly_revenue - prev_month_rev) / NULLIF(prev_month_rev, 0)) * 100, 2) AS mom_growth_pct,
    next_month_rev,
    running_total_revenue,
    ROUND(rolling_3m_avg_revenue, 2) AS rolling_3m_avg_revenue
FROM lag_lead_calc
ORDER BY year_month;

-- -----------------------------------------------------------------------------
-- 2. TOP N PER GROUP USING ROW_NUMBER & DENSE_RANK:
--    Top 3 Customers per Market by Total Profit
-- -----------------------------------------------------------------------------
WITH customer_market_profit AS (
    SELECT 
        m.market_name,
        c.customer_code,
        c.customer_name,
        c.customer_type,
        ROUND(SUM(s.sales_amount), 2) AS total_revenue,
        ROUND(SUM(s.profit_amount), 2) AS total_profit,
        ROW_NUMBER() OVER (PARTITION BY m.market_name ORDER BY SUM(s.profit_amount) DESC) AS row_num,
        DENSE_RANK() OVER (PARTITION BY m.market_name ORDER BY SUM(s.profit_amount) DESC) AS dense_rnk
    FROM sales_transactions s
    JOIN customers c ON s.customer_code = c.customer_code
    JOIN markets m ON s.market_code = m.market_code
    GROUP BY m.market_name, c.customer_code, c.customer_name, c.customer_type
)
SELECT 
    market_name,
    dense_rnk AS market_rank,
    customer_code,
    customer_name,
    customer_type,
    total_revenue,
    total_profit
FROM customer_market_profit
WHERE dense_rnk <= 3
ORDER BY market_name, market_rank;

-- -----------------------------------------------------------------------------
-- 3. PARETO 80/20 REVENUE CONTRIBUTION ANALYSIS:
--    Cumulative Contribution % by Customer
-- -----------------------------------------------------------------------------
WITH customer_revenue AS (
    SELECT 
        c.customer_code,
        c.customer_name,
        ROUND(SUM(s.sales_amount), 2) AS revenue
    FROM sales_transactions s
    JOIN customers c ON s.customer_code = c.customer_code
    GROUP BY c.customer_code, c.customer_name
),
cumulative_calc AS (
    SELECT 
        customer_code,
        customer_name,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS running_revenue,
        SUM(revenue) OVER () AS total_company_revenue
    FROM customer_revenue
)
SELECT 
    customer_code,
    customer_name,
    revenue,
    ROUND((revenue / total_company_revenue) * 100, 2) AS ind_contribution_pct,
    ROUND((running_revenue / total_company_revenue) * 100, 2) AS cumulative_contribution_pct,
    CASE 
        WHEN (running_revenue / total_company_revenue) <= 0.80 THEN 'Top 80% Drivers (Core VIP)'
        ELSE 'Remaining 20% Drivers'
    END AS pareto_group
FROM cumulative_calc
ORDER BY revenue DESC;

-- -----------------------------------------------------------------------------
-- 4. CUSTOMER REPEAT PURCHASING COHORT ANALYSIS:
--    First vs Last Order Date & Purchase Frequency
-- -----------------------------------------------------------------------------
WITH customer_cohort AS (
    SELECT 
        customer_code,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(transaction_id) AS total_orders,
        DATEDIFF(MAX(order_date), MIN(order_date)) AS tenure_days,
        ROUND(SUM(sales_amount), 2) AS lifetime_value
    FROM sales_transactions
    GROUP BY customer_code
)
SELECT 
    customer_code,
    first_order_date,
    last_order_date,
    total_orders,
    tenure_days,
    lifetime_value,
    ROUND(tenure_days / NULLIF(total_orders - 1, 0), 1) AS avg_days_between_orders,
    CASE 
        WHEN tenure_days >= 365 AND total_orders >= 10 THEN 'Loyal Frequent Buyer'
        WHEN tenure_days < 180 AND total_orders >= 5 THEN 'New Fast Adopted'
        ELSE 'Standard Customer'
    END AS cohort_segment
FROM customer_cohort
ORDER BY lifetime_value DESC;

-- -----------------------------------------------------------------------------
-- 5. BENCHMARKING WITH SUBQUERIES:
--    Products with Margin Higher than Category Average
-- -----------------------------------------------------------------------------
WITH product_margins AS (
    SELECT 
        p.product_code,
        p.product_name,
        p.category,
        ROUND(SUM(s.sales_amount), 2) AS prod_revenue,
        ROUND(SUM(s.profit_amount), 2) AS prod_profit,
        ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS prod_margin_pct
    FROM sales_transactions s
    JOIN products p ON s.product_code = p.product_code
    GROUP BY p.product_code, p.product_name, p.category
)
SELECT 
    pm.product_code,
    pm.product_name,
    pm.category,
    pm.prod_revenue,
    pm.prod_margin_pct,
    ROUND(cat_avg.avg_margin, 2) AS category_avg_margin_pct,
    ROUND(pm.prod_margin_pct - cat_avg.avg_margin, 2) AS margin_outperformance_pts
FROM product_margins pm
JOIN (
    SELECT 
        category,
        AVG(prod_margin_pct) AS avg_margin
    FROM product_margins
    GROUP BY category
) cat_avg ON pm.category = cat_avg.category
WHERE pm.prod_margin_pct > cat_avg.avg_margin
ORDER BY pm.category, margin_outperformance_pts DESC;
