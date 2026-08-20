-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 05_customer_analysis.sql
-- Description: Customer ranking, top contributors, Average Order Value (AOV),
--              repeat buyer behavior, and customer segmentation.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- Q1. WHO ARE THE TOP 10 CUSTOMERS BY REVENUE?
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    m.market_name,
    COUNT(s.transaction_id) AS total_orders,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit
FROM sales_transactions s
JOIN customers c ON s.customer_code = c.customer_code
JOIN markets m ON s.market_code = m.market_code
GROUP BY c.customer_code, c.customer_name, c.customer_type, m.market_name
ORDER BY total_revenue DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Q2. WHO ARE THE TOP 10 CUSTOMERS BY PROFIT?
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    m.market_name,
    COUNT(s.transaction_id) AS total_orders,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions s
JOIN customers c ON s.customer_code = c.customer_code
JOIN markets m ON s.market_code = m.market_code
GROUP BY c.customer_code, c.customer_name, c.customer_type, m.market_name
ORDER BY total_profit DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Q3. HOW MANY ORDERS HAS EACH CUSTOMER PLACED?
-- Q4. WHAT IS THE AVERAGE ORDER VALUE (AOV) PER CUSTOMER?
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    COUNT(s.transaction_id) AS order_count,
    SUM(s.order_qty) AS total_units_purchased,
    ROUND(SUM(s.sales_amount), 2) AS total_spent,
    ROUND(AVG(s.sales_amount), 2) AS average_order_value
FROM customers c
JOIN sales_transactions s ON c.customer_code = s.customer_code
GROUP BY c.customer_code, c.customer_name, c.customer_type
ORDER BY order_count DESC;

-- -----------------------------------------------------------------------------
-- Q5. WHICH CUSTOMERS ARE REPEAT CUSTOMERS? (Order count > 1)
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_type,
    COUNT(DISTINCT c.customer_code) AS customer_count,
    ROUND(AVG(customer_orders.order_count), 1) AS avg_orders_per_customer,
    ROUND(SUM(customer_orders.total_revenue), 2) AS total_segment_revenue
FROM customers c
JOIN (
    SELECT 
        customer_code, 
        COUNT(transaction_id) AS order_count,
        SUM(sales_amount) AS total_revenue
    FROM sales_transactions
    GROUP BY customer_code
    HAVING COUNT(transaction_id) > 1
) customer_orders ON c.customer_code = customer_orders.customer_code
GROUP BY c.customer_type
ORDER BY total_segment_revenue DESC;

-- -----------------------------------------------------------------------------
-- Q6. WHAT PERCENTAGE OF TOTAL REVENUE COMES FROM EACH CUSTOMER?
-- -----------------------------------------------------------------------------
WITH company_total AS (
    SELECT SUM(sales_amount) AS grand_total_sales FROM sales_transactions
)
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    ROUND(SUM(s.sales_amount), 2) AS customer_revenue,
    ROUND((SUM(s.sales_amount) / t.grand_total_sales) * 100, 2) AS revenue_contribution_pct
FROM sales_transactions s
JOIN customers c ON s.customer_code = c.customer_code
CROSS JOIN company_total t
GROUP BY c.customer_code, c.customer_name, c.customer_type, t.grand_total_sales
ORDER BY customer_revenue DESC
LIMIT 15;

-- -----------------------------------------------------------------------------
-- Q7. WHICH CUSTOMERS GENERATE ABOVE-AVERAGE REVENUE?
-- -----------------------------------------------------------------------------
WITH customer_totals AS (
    SELECT 
        customer_code,
        SUM(sales_amount) AS total_revenue
    FROM sales_transactions
    GROUP BY customer_code
),
avg_customer_spend AS (
    SELECT AVG(total_revenue) AS mean_spend FROM customer_totals
)
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    ROUND(ct.total_revenue, 2) AS customer_revenue,
    ROUND(a.mean_spend, 2) AS average_customer_spend,
    ROUND(ct.total_revenue - a.mean_spend, 2) AS spend_above_average
FROM customer_totals ct
JOIN customers c ON ct.customer_code = c.customer_code
CROSS JOIN avg_customer_spend a
WHERE ct.total_revenue > a.mean_spend
ORDER BY customer_revenue DESC;

-- -----------------------------------------------------------------------------
-- Q8. RANK CUSTOMERS BY REVENUE (Using DENSE_RANK)
-- Q9. RANK CUSTOMERS BY PROFIT (Using DENSE_RANK)
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS revenue_rank,
    ROUND(SUM(s.profit_amount), 2) AS total_profit,
    DENSE_RANK() OVER (ORDER BY SUM(s.profit_amount) DESC) AS profit_rank
FROM sales_transactions s
JOIN customers c ON s.customer_code = c.customer_code
GROUP BY c.customer_code, c.customer_name, c.customer_type
ORDER BY revenue_rank ASC
LIMIT 20;

-- -----------------------------------------------------------------------------
-- Q10. IDENTIFY HIGHEST-VALUE CUSTOMERS (ABC / Value Tier Classification)
-- -----------------------------------------------------------------------------
WITH customer_summary AS (
    SELECT 
        c.customer_code,
        c.customer_name,
        c.customer_type,
        ROUND(SUM(s.sales_amount), 2) AS total_revenue,
        NTILE(4) OVER (ORDER BY SUM(s.sales_amount) DESC) AS spend_quartile
    FROM sales_transactions s
    JOIN customers c ON s.customer_code = c.customer_code
    GROUP BY c.customer_code, c.customer_name, c.customer_type
)
SELECT 
    customer_code,
    customer_name,
    customer_type,
    total_revenue,
    CASE spend_quartile
        WHEN 1 THEN 'Platinum (Top 25%)'
        WHEN 2 THEN 'Gold (25%-50%)'
        WHEN 3 THEN 'Silver (50%-75%)'
        WHEN 4 THEN 'Bronze (Bottom 25%)'
    END AS customer_tier
FROM customer_summary
ORDER BY total_revenue DESC;
