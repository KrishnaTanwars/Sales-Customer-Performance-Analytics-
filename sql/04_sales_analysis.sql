-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 04_sales_analysis.sql
-- Description: Core sales metrics, yearly & monthly revenue trends, MoM growth %,
--              cumulative totals, and peak/trough analysis.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- Q1. WHAT IS TOTAL REVENUE?
-- Q2. WHAT IS TOTAL QUANTITY SOLD?
-- Q3. WHAT IS TOTAL COST?
-- Q4. WHAT IS GROSS PROFIT?
-- Q5. WHAT IS GROSS MARGIN PERCENTAGE?
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(transaction_id) AS total_transactions,
    SUM(order_qty) AS total_quantity_sold,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    ROUND(SUM(cost_amount), 2) AS total_cost,
    ROUND(SUM(profit_amount), 2) AS gross_profit,
    ROUND((SUM(profit_amount) / NULLIF(SUM(sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions;

-- -----------------------------------------------------------------------------
-- Q6. WHAT IS MONTHLY REVENUE?
-- -----------------------------------------------------------------------------
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    COUNT(transaction_id) AS total_transactions,
    SUM(order_qty) AS units_sold,
    ROUND(SUM(sales_amount), 2) AS monthly_revenue,
    ROUND(SUM(profit_amount), 2) AS monthly_profit,
    ROUND((SUM(profit_amount) / NULLIF(SUM(sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year_month;

-- -----------------------------------------------------------------------------
-- Q7. WHAT IS YEARLY REVENUE?
-- -----------------------------------------------------------------------------
SELECT 
    YEAR(order_date) AS sales_year,
    COUNT(transaction_id) AS total_transactions,
    SUM(order_qty) AS total_units_sold,
    ROUND(SUM(sales_amount), 2) AS yearly_revenue,
    ROUND(SUM(cost_amount), 2) AS yearly_cost,
    ROUND(SUM(profit_amount), 2) AS yearly_profit,
    ROUND((SUM(profit_amount) / NULLIF(SUM(sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions
GROUP BY YEAR(order_date)
ORDER BY sales_year;

-- -----------------------------------------------------------------------------
-- Q8. WHAT IS MONTHLY SALES GROWTH (MoM Growth %)?
-- -----------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS year_month,
        ROUND(SUM(sales_amount), 2) AS revenue
    FROM sales_transactions
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    year_month,
    revenue AS current_month_revenue,
    LAG(revenue) OVER (ORDER BY year_month) AS prior_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY year_month), 2) AS absolute_change,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY year_month)) / 
        NULLIF(LAG(revenue) OVER (ORDER BY year_month), 0)) * 100, 
        2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY year_month;

-- -----------------------------------------------------------------------------
-- Q9. WHAT IS CUMULATIVE SALES (RUNNING TOTAL)?
-- -----------------------------------------------------------------------------
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS year_month,
        ROUND(SUM(sales_amount), 2) AS monthly_revenue
    FROM sales_transactions
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    year_month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY year_month), 2) AS cumulative_revenue
FROM monthly_sales
ORDER BY year_month;

-- -----------------------------------------------------------------------------
-- Q10. WHAT ARE THE BEST AND WORST SALES MONTHS?
-- -----------------------------------------------------------------------------
WITH monthly_metrics AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS year_month,
        ROUND(SUM(sales_amount), 2) AS monthly_revenue,
        ROUND(SUM(profit_amount), 2) AS monthly_profit,
        RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS top_rank,
        RANK() OVER (ORDER BY SUM(sales_amount) ASC) AS bottom_rank
    FROM sales_transactions
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    year_month,
    monthly_revenue,
    monthly_profit,
    CASE 
        WHEN top_rank <= 3 THEN CONCAT('Top ', top_rank, ' Month')
        WHEN bottom_rank <= 3 THEN CONCAT('Bottom ', bottom_rank, ' Month')
        ELSE 'Normal Month'
    END AS performance_category
FROM monthly_metrics
WHERE top_rank <= 3 OR bottom_rank <= 3
ORDER BY monthly_revenue DESC;
