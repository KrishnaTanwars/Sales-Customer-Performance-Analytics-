import os
import sqlite3
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DATA_DIR = os.path.join(BASE_DIR, "data", "raw")

def run_tests():
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()

    # Load CSVs into SQLite
    print("Loading CSV files into SQLite test database...")
    for table_name in ["markets", "customers", "products", "targets", "sales_transactions"]:
        df = pd.read_csv(os.path.join(RAW_DATA_DIR, f"{table_name}.csv"))
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(f"Loaded {len(df)} rows into table `{table_name}`.")

    print("\n--- 1. OVERALL SALES METRICS ---")
    sales_summary = pd.read_sql_query("""
        SELECT 
            COUNT(*) AS total_transactions,
            SUM(order_qty) AS total_units_sold,
            ROUND(SUM(sales_amount), 2) AS total_revenue,
            ROUND(SUM(cost_amount), 2) AS total_cost,
            ROUND(SUM(profit_amount), 2) AS total_gross_profit,
            ROUND((SUM(profit_amount) / SUM(sales_amount)) * 100, 2) AS gross_margin_pct
        FROM sales_transactions;
    """, conn)
    print(sales_summary.to_string(index=False))

    print("\n--- 2. YEARLY SALES PERFORMANCE ---")
    yearly_sales = pd.read_sql_query("""
        SELECT 
            STRFTIME('%Y', order_date) AS sales_year,
            COUNT(*) AS transactions,
            SUM(order_qty) AS total_qty,
            ROUND(SUM(sales_amount), 2) AS total_revenue,
            ROUND(SUM(profit_amount), 2) AS gross_profit,
            ROUND((SUM(profit_amount) / SUM(sales_amount)) * 100, 2) AS gross_margin_pct
        FROM sales_transactions
        GROUP BY 1
        ORDER BY 1;
    """, conn)
    print(yearly_sales.to_string(index=False))

    print("\n--- 3. TOP 5 CUSTOMERS BY REVENUE ---")
    top_cust = pd.read_sql_query("""
        SELECT 
            c.customer_code,
            c.customer_name,
            c.customer_type,
            m.market_name,
            COUNT(s.transaction_id) AS total_orders,
            ROUND(SUM(s.sales_amount), 2) AS total_revenue,
            ROUND(SUM(s.profit_amount), 2) AS total_profit,
            DENSE_RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS revenue_rank
        FROM sales_transactions s
        JOIN customers c ON s.customer_code = c.customer_code
        JOIN markets m ON s.market_code = m.market_code
        GROUP BY c.customer_code, c.customer_name, c.customer_type, m.market_name
        ORDER BY total_revenue DESC
        LIMIT 5;
    """, conn)
    print(top_cust.to_string(index=False))

    print("\n--- 4. CATEGORY PERFORMANCE ---")
    cat_perf = pd.read_sql_query("""
        SELECT 
            p.category,
            COUNT(s.transaction_id) AS transaction_count,
            SUM(s.order_qty) AS total_qty_sold,
            ROUND(SUM(s.sales_amount), 2) AS category_revenue,
            ROUND(SUM(s.profit_amount), 2) AS category_profit,
            ROUND((SUM(s.profit_amount) / SUM(s.sales_amount)) * 100, 2) AS gross_margin_pct,
            ROUND((SUM(s.sales_amount) / (SELECT SUM(sales_amount) FROM sales_transactions)) * 100, 2) AS revenue_contribution_pct
        FROM sales_transactions s
        JOIN products p ON s.product_code = p.product_code
        GROUP BY p.category
        ORDER BY category_revenue DESC;
    """, conn)
    print(cat_perf.to_string(index=False))

    print("\n--- 5. MARKET PERFORMANCE & TARGET ACHIEVEMENT ---")
    market_target = pd.read_sql_query("""
        WITH actuals AS (
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
            a.actual_sales,
            ROUND(a.actual_sales - t.target_sales, 2) AS sales_variance,
            ROUND((a.actual_sales / t.target_sales) * 100, 2) AS achievement_pct,
            CASE 
                WHEN a.actual_sales >= t.target_sales THEN 'Target Achieved'
                ELSE 'Target Missed'
            END AS target_status,
            a.actual_profit,
            ROUND((a.actual_profit / a.actual_sales) * 100, 2) AS gross_margin_pct
        FROM markets m
        JOIN target_totals t ON m.market_code = t.market_code
        JOIN actuals a ON m.market_code = a.market_code
        ORDER BY actual_sales DESC;
    """, conn)
    print(market_target.to_string(index=False))

    print("\n--- 6. TOP 3 PRODUCTS PER CATEGORY ---")
    top_p_cat = pd.read_sql_query("""
        WITH product_sales AS (
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
        SELECT *
        FROM product_sales
        WHERE rank_in_category <= 3
        ORDER BY category, rank_in_category;
    """, conn)
    print(top_p_cat.to_string(index=False))

    print("\n--- 7. MONTH-OVER-MONTH GROWTH & RUNNING TOTAL (SAMPLE 2025) ---")
    mom_sales = pd.read_sql_query("""
        WITH monthly_sales AS (
            SELECT 
                STRFTIME('%Y-%m', order_date) AS year_month,
                ROUND(SUM(sales_amount), 2) AS monthly_revenue
            FROM sales_transactions
            GROUP BY 1
        )
        SELECT 
            year_month,
            monthly_revenue,
            LAG(monthly_revenue) OVER (ORDER BY year_month) AS prev_month_revenue,
            ROUND(monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year_month), 2) AS mom_revenue_change,
            ROUND(((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year_month)) / LAG(monthly_revenue) OVER (ORDER BY year_month)) * 100, 2) AS mom_growth_pct,
            ROUND(SUM(monthly_revenue) OVER (ORDER BY year_month), 2) AS cumulative_revenue
        FROM monthly_sales
        ORDER BY year_month;
    """, conn)
    print(mom_sales.tail(12).to_string(index=False))

    conn.close()
    print("\nQuery validation completed successfully!")

if __name__ == "__main__":
    run_tests()
