-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 07_market_analysis.sql
-- Description: Market-level revenue, profitability, regional rankings,
--              company benchmark comparison, and zone analysis.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- Q1. REVENUE BY MARKET
-- Q2. PROFIT BY MARKET
-- Q3. GROSS MARGIN BY MARKET
-- Q4. MARKET REVENUE CONTRIBUTION %
-- Q5. MARKET RANKING
-- -----------------------------------------------------------------------------
WITH grand_totals AS (
    SELECT SUM(sales_amount) AS total_company_sales FROM sales_transactions
)
SELECT 
    m.market_code,
    m.market_name,
    m.zone,
    m.region,
    COUNT(s.transaction_id) AS total_orders,
    ROUND(SUM(s.sales_amount), 2) AS market_revenue,
    ROUND(SUM(s.cost_amount), 2) AS market_cost,
    ROUND(SUM(s.profit_amount), 2) AS market_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct,
    ROUND((SUM(s.sales_amount) / gt.total_company_sales) * 100, 2) AS revenue_contribution_pct,
    DENSE_RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS market_rank
FROM sales_transactions s
JOIN markets m ON s.market_code = m.market_code
CROSS JOIN grand_totals gt
GROUP BY m.market_code, m.market_name, m.zone, m.region, gt.total_company_sales
ORDER BY market_rank;

-- -----------------------------------------------------------------------------
-- Q6. TOP MARKETS (Top 3 by Revenue & Profit)
-- Q7. BOTTOM MARKETS (Bottom 3 by Revenue & Profit)
-- -----------------------------------------------------------------------------
WITH market_summary AS (
    SELECT 
        m.market_code,
        m.market_name,
        m.zone,
        ROUND(SUM(s.sales_amount), 2) AS total_revenue,
        ROUND(SUM(s.profit_amount), 2) AS total_profit,
        RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS rank_desc,
        RANK() OVER (ORDER BY SUM(s.sales_amount) ASC) AS rank_asc
    FROM sales_transactions s
    JOIN markets m ON s.market_code = m.market_code
    GROUP BY m.market_code, m.market_name, m.zone
)
SELECT 
    market_code,
    market_name,
    zone,
    total_revenue,
    total_profit,
    CASE 
        WHEN rank_desc <= 3 THEN CONCAT('Top Market #', rank_desc)
        WHEN rank_asc <= 3 THEN CONCAT('Bottom Market #', rank_asc)
    END AS tier_classification
FROM market_summary
WHERE rank_desc <= 3 OR rank_asc <= 3
ORDER BY total_revenue DESC;

-- -----------------------------------------------------------------------------
-- Q8. MARKETS ABOVE COMPANY AVERAGE
-- Q9. MARKETS BELOW COMPANY AVERAGE
-- -----------------------------------------------------------------------------
WITH market_totals AS (
    SELECT 
        m.market_code,
        m.market_name,
        m.zone,
        ROUND(SUM(s.sales_amount), 2) AS market_revenue
    FROM sales_transactions s
    JOIN markets m ON s.market_code = m.market_code
    GROUP BY m.market_code, m.market_name, m.zone
),
avg_market AS (
    SELECT AVG(market_revenue) AS mean_market_revenue FROM market_totals
)
SELECT 
    mt.market_code,
    mt.market_name,
    mt.zone,
    mt.market_revenue,
    ROUND(am.mean_market_revenue, 2) AS company_avg_market_revenue,
    ROUND(mt.market_revenue - am.mean_market_revenue, 2) AS variance_from_avg,
    CASE 
        WHEN mt.market_revenue >= am.mean_market_revenue THEN 'Above Company Average'
        ELSE 'Below Company Average'
    END AS benchmark_status
FROM market_totals mt
CROSS JOIN avg_market am
ORDER BY mt.market_revenue DESC;

-- -----------------------------------------------------------------------------
-- Q10. MARKET-LEVEL PERFORMANCE TRENDS (Zone & Yearly Distribution)
-- -----------------------------------------------------------------------------
SELECT 
    m.zone,
    YEAR(s.order_date) AS sales_year,
    COUNT(s.transaction_id) AS total_orders,
    ROUND(SUM(s.sales_amount), 2) AS zone_revenue,
    ROUND(SUM(s.profit_amount), 2) AS zone_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions s
JOIN markets m ON s.market_code = m.market_code
GROUP BY m.zone, YEAR(s.order_date)
ORDER BY m.zone, sales_year;
