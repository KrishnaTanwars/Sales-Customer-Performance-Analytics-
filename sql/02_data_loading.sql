-- =============================================================================
-- Project: Sales & Customer Performance Analytics | SQL
-- Dialect: MySQL 8.0+
-- File: 02_data_loading.sql
-- Description: LOAD DATA INFILE procedures, configuration settings, and 
--              alternative batch loading methods for all 5 entities.
-- =============================================================================

USE sales_analytics_db;

-- -----------------------------------------------------------------------------
-- 1. PRE-REQUISITE CONFIGURATION & SECURITY NOTES
-- -----------------------------------------------------------------------------
-- MySQL requires `local_infile` to be enabled on both client and server:
-- To enable in MySQL session:
SET GLOBAL local_infile = 1;

-- -----------------------------------------------------------------------------
-- 2. LOAD MARKETS DATA
-- -----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE '../data/raw/markets.csv'
INTO TABLE markets
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(market_code, market_name, zone, region);

-- -----------------------------------------------------------------------------
-- 3. LOAD PRODUCTS DATA
-- -----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE '../data/raw/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_code, product_name, category, sub_category, unit_cost, unit_price);

-- -----------------------------------------------------------------------------
-- 4. LOAD CUSTOMERS DATA
-- -----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE '../data/raw/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_code, customer_name, customer_type, market_code);

-- -----------------------------------------------------------------------------
-- 5. LOAD TARGETS DATA
-- -----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE '../data/raw/targets.csv'
INTO TABLE targets
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(market_code, target_year, target_month, target_sales);

-- -----------------------------------------------------------------------------
-- 6. LOAD SALES TRANSACTIONS DATA (105,000+ ROWS)
-- -----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE '../data/raw/sales_transactions.csv'
INTO TABLE sales_transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transaction_id, order_date, customer_code, product_code, market_code, 
 order_qty, unit_price, unit_cost, discount_pct, sales_amount, cost_amount, profit_amount);

-- -----------------------------------------------------------------------------
-- 7. ALTERNATIVE GUI & SECURE IMPORT INSTRUCTIONS
-- -----------------------------------------------------------------------------
/*
If local INFILE is restricted in your MySQL production environment:
Option A (MySQL Workbench Table Data Import Wizard):
1. Right-click target table -> Select 'Table Data Import Wizard'.
2. Select target CSV file from data/raw/.
3. Match CSV column mapping to table schema.
4. Execute batch import.

Option B (Command Line MySQL Client):
mysql --local-infile=1 -u root -p sales_analytics_db < 02_data_loading.sql

Option C (Python Automated Loader):
python scripts/test_queries.py
*/
