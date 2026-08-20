-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 06_product_analysis.sql
-- Description: Product rankings, category breakdowns, margin contribution,
--              top products per category, and YoY product performance comparison.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- Q1. TOP 10 PRODUCTS BY REVENUE
-- -----------------------------------------------------------------------------
SELECT 
    p.product_code,
    p.product_name,
    p.category,
    SUM(s.order_qty) AS total_units_sold,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit
FROM sales_transactions s
JOIN products p ON s.product_code = p.product_code
GROUP BY p.product_code, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Q2. TOP 10 PRODUCTS BY PROFIT
-- -----------------------------------------------------------------------------
SELECT 
    p.product_code,
    p.product_name,
    p.category,
    SUM(s.order_qty) AS total_units_sold,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions s
JOIN products p ON s.product_code = p.product_code
GROUP BY p.product_code, p.product_name, p.category
ORDER BY total_profit DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Q3. REVENUE BY CATEGORY
-- Q4. PROFIT BY CATEGORY
-- Q5. GROSS MARGIN BY CATEGORY
-- Q6. PRODUCT REVENUE CONTRIBUTION % BY CATEGORY
-- -----------------------------------------------------------------------------
WITH company_total AS (
    SELECT SUM(sales_amount) AS grand_total FROM sales_transactions
)
SELECT 
    p.category,
    COUNT(DISTINCT p.product_code) AS product_count,
    COUNT(s.transaction_id) AS transaction_count,
    SUM(s.order_qty) AS total_units_sold,
    ROUND(SUM(s.sales_amount), 2) AS category_revenue,
    ROUND(SUM(s.cost_amount), 2) AS category_cost,
    ROUND(SUM(s.profit_amount), 2) AS category_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct,
    ROUND((SUM(s.sales_amount) / ct.grand_total) * 100, 2) AS revenue_contribution_pct
FROM sales_transactions s
JOIN products p ON s.product_code = p.product_code
CROSS JOIN company_total ct
GROUP BY p.category, ct.grand_total
ORDER BY category_revenue DESC;

-- -----------------------------------------------------------------------------
-- Q7. LOW-PERFORMING PRODUCTS (BOTTOM 10 BY REVENUE)
-- -----------------------------------------------------------------------------
SELECT 
    p.product_code,
    p.product_name,
    p.category,
    SUM(s.order_qty) AS total_units_sold,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit
FROM sales_transactions s
JOIN products p ON s.product_code = p.product_code
GROUP BY p.product_code, p.product_name, p.category
ORDER BY total_revenue ASC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Q8. TOP 3 PRODUCTS WITHIN EACH CATEGORY (Using Window Functions)
-- -----------------------------------------------------------------------------
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
SELECT 
    category,
    rank_in_category,
    product_code,
    product_name,
    product_revenue,
    product_profit
FROM ranked_products
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

-- -----------------------------------------------------------------------------
-- Q9. PRODUCTS WITH REVENUE ABOVE CATEGORY AVERAGE
-- -----------------------------------------------------------------------------
WITH product_sales AS (
    SELECT 
        p.category,
        p.product_code,
        p.product_name,
        ROUND(SUM(s.sales_amount), 2) AS product_revenue
    FROM sales_transactions s
    JOIN products p ON s.product_code = p.product_code
    GROUP BY p.category, p.product_code, p.product_name
),
category_avg AS (
    SELECT 
        category,
        AVG(product_revenue) AS avg_cat_revenue
    FROM product_sales
    GROUP BY category
)
SELECT 
    ps.category,
    ps.product_code,
    ps.product_name,
    ps.product_revenue,
    ROUND(ca.avg_cat_revenue, 2) AS category_average_revenue,
    ROUND(ps.product_revenue - ca.avg_cat_revenue, 2) AS excess_above_avg
FROM product_sales ps
JOIN category_avg ca ON ps.category = ca.category
WHERE ps.product_revenue > ca.avg_cat_revenue
ORDER BY ps.category, excess_above_avg DESC;

-- -----------------------------------------------------------------------------
-- Q10. PRODUCTS WITH DECLINING PERFORMANCE (YoY Comparison 2024 vs 2025)
-- -----------------------------------------------------------------------------
WITH product_yearly AS (
    SELECT 
        p.product_code,
        p.product_name,
        p.category,
        ROUND(SUM(CASE WHEN YEAR(s.order_date) = 2024 THEN s.sales_amount ELSE 0 END), 2) AS revenue_2024,
        ROUND(SUM(CASE WHEN YEAR(s.order_date) = 2025 THEN s.sales_amount ELSE 0 END), 2) AS revenue_2025
    FROM sales_transactions s
    JOIN products p ON s.product_code = p.product_code
    GROUP BY p.product_code, p.product_name, p.category
)
SELECT 
    product_code,
    product_name,
    category,
    revenue_2024,
    revenue_2025,
    ROUND(revenue_2025 - revenue_2024, 2) AS yoy_change,
    ROUND(((revenue_2025 - revenue_2024) / NULLIF(revenue_2024, 0)) * 100, 2) AS yoy_growth_pct
FROM product_yearly
WHERE revenue_2024 > 0
ORDER BY yoy_change ASC
LIMIT 10;
