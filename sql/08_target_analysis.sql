-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 08_target_analysis.sql
-- Description: Actual vs Target performance analysis, sales variance, achievement %,
--              status classification, and positive/negative gap detection.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- 1. MASTER MARKET TARGET VS ACTUAL SUMMARY (Overall Project Period)
-- -----------------------------------------------------------------------------
WITH actual_totals AS (
    SELECT 
        market_code,
        ROUND(SUM(sales_amount), 2) AS actual_sales,
        ROUND(SUM(profit_amount), 2) AS actual_profit
    FROM sales_transactions
    GROUP BY market_code
),
target_totals AS (
    SELECT 
        market_code,
        ROUND(SUM(target_sales), 2) AS target_sales
    FROM targets
    GROUP BY market_code
)
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
JOIN target_totals t ON m.market_code = t.market_code
LEFT JOIN actual_totals a ON m.market_code = a.market_code
ORDER BY actual_sales DESC;

-- -----------------------------------------------------------------------------
-- 2. YEARLY TARGET VS ACTUAL PERFORMANCE BY MARKET
-- -----------------------------------------------------------------------------
WITH actual_yearly AS (
    SELECT 
        market_code,
        YEAR(order_date) AS sales_year,
        ROUND(SUM(sales_amount), 2) AS actual_sales
    FROM sales_transactions
    GROUP BY market_code, YEAR(order_date)
),
target_yearly AS (
    SELECT 
        market_code,
        target_year AS sales_year,
        ROUND(SUM(target_sales), 2) AS target_sales
    FROM targets
    GROUP BY market_code, target_year
)
SELECT 
    m.market_code,
    m.market_name,
    ty.sales_year,
    ty.target_sales,
    COALESCE(ay.actual_sales, 0.00) AS actual_sales,
    ROUND(COALESCE(ay.actual_sales, 0.00) - ty.target_sales, 2) AS variance,
    ROUND((COALESCE(ay.actual_sales, 0.00) / NULLIF(ty.target_sales, 0)) * 100, 2) AS achievement_pct,
    CASE 
        WHEN COALESCE(ay.actual_sales, 0.00) >= ty.target_sales THEN 'Target Achieved'
        ELSE 'Target Missed'
    END AS status
FROM markets m
JOIN target_yearly ty ON m.market_code = ty.market_code
LEFT JOIN actual_yearly ay ON ty.market_code = ay.market_code AND ty.sales_year = ay.sales_year
ORDER BY m.market_code, ty.sales_year;

-- -----------------------------------------------------------------------------
-- 3. MARKETS THAT ACHIEVED TARGETS VS MISSED TARGETS SUMMARY
-- -----------------------------------------------------------------------------
WITH market_perf AS (
    SELECT 
        m.market_code,
        m.market_name,
        ROUND(SUM(s.sales_amount), 2) AS actual_sales,
        ROUND(SUM(t.target_sales), 2) AS target_sales
    FROM markets m
    JOIN sales_transactions s ON m.market_code = s.market_code
    JOIN targets t ON m.market_code = t.market_code
    GROUP BY m.market_code, m.market_name
)
SELECT 
    CASE 
        WHEN actual_sales >= target_sales THEN 'Target Achieved'
        ELSE 'Target Missed'
    END AS target_status,
    COUNT(*) AS market_count,
    ROUND(AVG((actual_sales / target_sales) * 100), 2) AS avg_achievement_pct
FROM market_perf
GROUP BY target_status;

-- -----------------------------------------------------------------------------
-- 4. EXTREME VARIANCES (Largest Positive & Largest Negative Variance)
-- -----------------------------------------------------------------------------
WITH variance_calc AS (
    SELECT 
        m.market_name,
        ROUND(SUM(s.sales_amount), 2) AS actual_sales,
        ROUND(SUM(t.target_sales), 2) AS target_sales,
        ROUND(SUM(s.sales_amount) - SUM(t.target_sales), 2) AS sales_variance,
        ROUND((SUM(s.sales_amount) / SUM(t.target_sales)) * 100, 2) AS achievement_pct
    FROM markets m
    JOIN sales_transactions s ON m.market_code = s.market_code
    JOIN targets t ON m.market_code = t.market_code
    GROUP BY m.market_code, m.market_name
)
(
    SELECT 'Highest Achievement %' AS metric_type, market_name, actual_sales, target_sales, sales_variance, achievement_pct
    FROM variance_calc ORDER BY achievement_pct DESC LIMIT 1
)
UNION ALL
(
    SELECT 'Lowest Achievement %' AS metric_type, market_name, actual_sales, target_sales, sales_variance, achievement_pct
    FROM variance_calc ORDER BY achievement_pct ASC LIMIT 1
)
UNION ALL
(
    SELECT 'Largest Positive Variance' AS metric_type, market_name, actual_sales, target_sales, sales_variance, achievement_pct
    FROM variance_calc ORDER BY sales_variance DESC LIMIT 1
)
UNION ALL
(
    SELECT 'Largest Negative Variance' AS metric_type, market_name, actual_sales, target_sales, sales_variance, achievement_pct
    FROM variance_calc ORDER BY sales_variance ASC LIMIT 1
);
