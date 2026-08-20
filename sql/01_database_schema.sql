-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 01_database_schema.sql
-- Description: Creates database, relational tables, primary keys, foreign keys,
--              indexes, and core analytical views.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. DATABASE CREATION
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS sales_analytics_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- 2. DROP TABLES IF EXIST (Order respects FK constraints)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS sales_transactions;
DROP TABLE IF EXISTS targets;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS markets;

-- -----------------------------------------------------------------------------
-- 3. MARKETS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE markets (
    market_code VARCHAR(20) NOT NULL,
    market_name VARCHAR(100) NOT NULL,
    zone VARCHAR(50) NOT NULL,
    region VARCHAR(100) NOT NULL,
    CONSTRAINT pk_markets PRIMARY KEY (market_code),
    CONSTRAINT uk_market_name UNIQUE (market_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 4. PRODUCTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    product_code VARCHAR(20) NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    sub_category VARCHAR(100) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT pk_products PRIMARY KEY (product_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 5. CUSTOMERS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_code VARCHAR(20) NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    customer_type VARCHAR(50) NOT NULL,
    market_code VARCHAR(20) NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_code),
    CONSTRAINT fk_customers_markets FOREIGN KEY (market_code) 
        REFERENCES markets (market_code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 6. TARGETS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE targets (
    market_code VARCHAR(20) NOT NULL,
    target_year INT NOT NULL CHECK (target_year BETWEEN 2000 AND 2100),
    target_month INT NOT NULL CHECK (target_month BETWEEN 1 AND 12),
    target_sales DECIMAL(12,2) NOT NULL CHECK (target_sales >= 0),
    CONSTRAINT pk_targets PRIMARY KEY (market_code, target_year, target_month),
    CONSTRAINT fk_targets_markets FOREIGN KEY (market_code) 
        REFERENCES markets (market_code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 7. SALES TRANSACTIONS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE sales_transactions (
    transaction_id VARCHAR(30) NOT NULL,
    order_date DATE NOT NULL,
    customer_code VARCHAR(20) NOT NULL,
    product_code VARCHAR(20) NOT NULL,
    market_code VARCHAR(20) NOT NULL,
    order_qty INT NOT NULL CHECK (order_qty > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    discount_pct DECIMAL(4,2) NOT NULL DEFAULT 0.00 CHECK (discount_pct BETWEEN 0.00 AND 1.00),
    sales_amount DECIMAL(12,2) NOT NULL CHECK (sales_amount >= 0),
    cost_amount DECIMAL(12,2) NOT NULL CHECK (cost_amount >= 0),
    profit_amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT pk_sales_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT fk_sales_customers FOREIGN KEY (customer_code) 
        REFERENCES customers (customer_code) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sales_products FOREIGN KEY (product_code) 
        REFERENCES products (product_code) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sales_markets FOREIGN KEY (market_code) 
        REFERENCES markets (market_code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 8. INDEXES FOR QUERY OPTIMIZATION
-- -----------------------------------------------------------------------------
CREATE INDEX idx_sales_order_date ON sales_transactions(order_date);
CREATE INDEX idx_sales_cust_prod ON sales_transactions(customer_code, product_code);
CREATE INDEX idx_sales_mkt_date ON sales_transactions(market_code, order_date);
CREATE INDEX idx_products_category ON products(category);

-- -----------------------------------------------------------------------------
-- 9. ANALYTICAL VIEWS
-- -----------------------------------------------------------------------------

-- View 1: Monthly Sales Aggregations
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(transaction_id) AS total_transactions,
    SUM(order_qty) AS total_units_sold,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    ROUND(SUM(cost_amount), 2) AS total_cost,
    ROUND(SUM(profit_amount), 2) AS gross_profit,
    ROUND((SUM(profit_amount) / NULLIF(SUM(sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM sales_transactions
GROUP BY DATE_FORMAT(order_date, '%Y-%m'), YEAR(order_date), MONTH(order_date);

-- View 2: Customer Performance Summary
CREATE OR REPLACE VIEW vw_customer_performance AS
SELECT 
    c.customer_code,
    c.customer_name,
    c.customer_type,
    m.market_name,
    m.zone,
    COUNT(s.transaction_id) AS total_orders,
    SUM(s.order_qty) AS total_units,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit,
    ROUND(AVG(s.sales_amount), 2) AS average_order_value,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM customers c
JOIN markets m ON c.market_code = m.market_code
JOIN sales_transactions s ON c.customer_code = s.customer_code
GROUP BY c.customer_code, c.customer_name, c.customer_type, m.market_name, m.zone;

-- View 3: Product Performance Summary
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT 
    p.product_code,
    p.product_name,
    p.category,
    p.sub_category,
    COUNT(s.transaction_id) AS total_orders,
    SUM(s.order_qty) AS total_qty_sold,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.profit_amount), 2) AS total_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM products p
JOIN sales_transactions s ON p.product_code = s.product_code
GROUP BY p.product_code, p.product_name, p.category, p.sub_category;

-- View 4: Market Performance Summary
CREATE OR REPLACE VIEW vw_market_performance AS
SELECT 
    m.market_code,
    m.market_name,
    m.zone,
    m.region,
    COUNT(s.transaction_id) AS total_transactions,
    SUM(s.order_qty) AS total_units_sold,
    ROUND(SUM(s.sales_amount), 2) AS total_revenue,
    ROUND(SUM(s.cost_amount), 2) AS total_cost,
    ROUND(SUM(s.profit_amount), 2) AS total_profit,
    ROUND((SUM(s.profit_amount) / NULLIF(SUM(s.sales_amount), 0)) * 100, 2) AS gross_margin_pct
FROM markets m
JOIN sales_transactions s ON m.market_code = s.market_code
GROUP BY m.market_code, m.market_name, m.zone, m.region;

-- View 5: Target vs Actual Performance
CREATE OR REPLACE VIEW vw_target_performance AS
WITH actual_monthly AS (
    SELECT 
        market_code,
        YEAR(order_date) AS sales_year,
        MONTH(order_date) AS sales_month,
        ROUND(SUM(sales_amount), 2) AS actual_sales,
        ROUND(SUM(profit_amount), 2) AS actual_profit
    FROM sales_transactions
    GROUP BY market_code, YEAR(order_date), MONTH(order_date)
)
SELECT 
    m.market_code,
    m.market_name,
    m.zone,
    t.target_year,
    t.target_month,
    t.target_sales,
    COALESCE(a.actual_sales, 0.00) AS actual_sales,
    ROUND(COALESCE(a.actual_sales, 0.00) - t.target_sales, 2) AS sales_variance,
    ROUND((COALESCE(a.actual_sales, 0.00) / NULLIF(t.target_sales, 0)) * 100, 2) AS achievement_pct,
    CASE 
        WHEN COALESCE(a.actual_sales, 0.00) >= t.target_sales THEN 'Target Achieved'
        ELSE 'Target Missed'
    END AS target_status
FROM targets t
JOIN markets m ON t.market_code = m.market_code
LEFT JOIN actual_monthly a 
    ON t.market_code = a.market_code 
   AND t.target_year = a.sales_year 
   AND t.target_month = a.sales_month;
