-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 03_data_quality.sql
-- Description: Data auditing, data quality verification, referential integrity
--              checks, and anomaly detection queries.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- 1. ROW COUNT VERIFICATION
-- -----------------------------------------------------------------------------
SELECT 'markets' AS table_name, COUNT(*) AS row_count FROM markets
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'targets', COUNT(*) FROM targets
UNION ALL
SELECT 'sales_transactions', COUNT(*) FROM sales_transactions;

-- -----------------------------------------------------------------------------
-- 2. NULL VALUE & CRITICAL FIELD AUDIT
-- -----------------------------------------------------------------------------
-- Audit transactions for missing foreign keys or mandatory numbers
SELECT 
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_trx_ids,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_dates,
    SUM(CASE WHEN customer_code IS NULL THEN 1 ELSE 0 END) AS null_cust_codes,
    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END) AS null_prod_codes,
    SUM(CASE WHEN market_code IS NULL THEN 1 ELSE 0 END) AS null_mkt_codes,
    SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS null_sales_amounts
FROM sales_transactions;

-- -----------------------------------------------------------------------------
-- 3. DUPLICATE TRANSACTION AUDIT
-- -----------------------------------------------------------------------------
SELECT 
    transaction_id, 
    COUNT(*) AS duplicate_count
FROM sales_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- 4. REFERENTIAL INTEGRITY AUDIT (Orphan Foreign Keys)
-- -----------------------------------------------------------------------------
-- Check for sales referencing non-existent customers
SELECT COUNT(*) AS orphan_customer_refs
FROM sales_transactions s
LEFT JOIN customers c ON s.customer_code = c.customer_code
WHERE c.customer_code IS NULL;

-- Check for sales referencing non-existent products
SELECT COUNT(*) AS orphan_product_refs
FROM sales_transactions s
LEFT JOIN products p ON s.product_code = p.product_code
WHERE p.product_code IS NULL;

-- Check for sales referencing non-existent markets
SELECT COUNT(*) AS orphan_market_refs
FROM sales_transactions s
LEFT JOIN markets m ON s.market_code = m.market_code
WHERE m.market_code IS NULL;

-- -----------------------------------------------------------------------------
-- 5. NUMERICAL SANITY & NEGATIVE VALUE CHECKS
-- -----------------------------------------------------------------------------
SELECT 
    SUM(CASE WHEN order_qty <= 0 THEN 1 ELSE 0 END) AS invalid_quantities,
    SUM(CASE WHEN unit_price < 0 THEN 1 ELSE 0 END) AS invalid_unit_prices,
    SUM(CASE WHEN unit_cost < 0 THEN 1 ELSE 0 END) AS invalid_unit_costs,
    SUM(CASE WHEN sales_amount < 0 THEN 1 ELSE 0 END) AS negative_sales_amounts,
    SUM(CASE WHEN discount_pct < 0 OR discount_pct > 1 THEN 1 ELSE 0 END) AS invalid_discounts
FROM sales_transactions;

-- -----------------------------------------------------------------------------
-- 6. DATE RANGE & SANITY AUDIT
-- -----------------------------------------------------------------------------
SELECT 
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS total_days_covered
FROM sales_transactions;

-- -----------------------------------------------------------------------------
-- 7. TARGET COVERAGE AUDIT
-- -----------------------------------------------------------------------------
-- Check if all markets have 36 months of target entries (2023-2025)
SELECT 
    m.market_code,
    m.market_name,
    COUNT(t.target_sales) AS target_months_recorded
FROM markets m
LEFT JOIN targets t ON m.market_code = t.market_code
GROUP BY m.market_code, m.market_name
HAVING target_months_recorded <> 36;
