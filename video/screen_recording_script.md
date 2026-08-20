# Screen Recording Video Script — Portfolio Case Study

**Project:** Sales & Customer Performance Analytics | SQL  
**Target Video Duration:** 5–8 minutes  
**Format:** Professional Case Study Walkthrough  
**Style:** Confident, articulate, business-focused natural spoken English  

---

## Script Breakdown & Spoken Narration

### 00:00 – 00:20 | Segment 1: The Hook
**Visual on Screen:** GitHub Repository Header or SQL Query Editor displaying the Master Schema.  
**Spoken Narration:**  
> "Hi everyone! In this portfolio case study, I’m presenting a complete, production-grade SQL analytics project: **Sales and Customer Performance Analytics**. 
> When organizations scale, leadership often struggles to connect raw transaction logs with actual commercial performance. Today, I’ll walk you through how I architected a MySQL database over **105,000 sales transactions** totaling **$167.7 million in revenue**, evaluated target achievement across global markets, and extracted actionable commercial strategy."

---

### 00:20 – 00:50 | Segment 2: Project Overview
**Visual on Screen:** `README.md` file displaying the Project Architecture, Objectives, and Technology Stack.  
**Spoken Narration:**  
> "The goal of this project is to answer critical executive questions around sales velocity, customer lifetime value, product margin optimization, and regional target variance. 
> Using MySQL 8+, I built a full analytics pipeline containing 5 relational tables, 5 production views, and over 30 analytical queries using advanced SQL techniques like multi-step CTEs, window functions, and running aggregations."

---

### 00:50 – 01:30 | Segment 3: The Dataset
**Visual on Screen:** `data/raw/` directory files (`sales_transactions.csv`, `customers.csv`, `products.csv`).  
**Spoken Narration:**  
> "Let me show you the dataset. The core fact table contains **105,000 transaction records** spanning three fiscal years from 2023 through 2025. 
> Each record captures order dates, customer accounts, product SKUs, quantities, unit prices, unit costs, discounts, and total net profit. Surrounding the fact table are dimension tables representing 10 global markets across 4 zones, 150 B2B corporate customers, 50 catalog products, and monthly market targets."

---

### 01:30 – 02:00 | Segment 4: Database Schema & Architecture
**Visual on Screen:** Entity-Relationship (ER) Diagram rendered in `documentation/data_dictionary.md` or MySQL Workbench ER Diagram.  
**Spoken Narration:**  
> "Here is the database schema defined in `01_database_schema.sql`. The schema is fully normalized in Third Normal Form. 
> Primary and Foreign Keys enforce strict referential integrity with cascading updates. I also added indexes on order dates, customer codes, and composite market-date columns to optimize analytical query execution speed across 100,000+ rows."

---

### 02:00 – 03:00 | Segment 5: Sales Performance Analysis
**Visual on Screen:** MySQL Workbench or DBeaver executing `04_sales_analysis.sql` (KPI summary and MoM growth queries).  
**Spoken Narration:**  
> "Now let me demonstrate our core sales queries. When we execute our overall sales KPI query, we see that across 105,000 orders, total revenue reached **$167,693,927.24** with **$66,641,864.24** in gross profit—maintaining a solid **39.74% gross margin**. 
> Looking at our monthly revenue and MoM growth query using the `LAG()` window function, we observe strong Q4 seasonality, with November and December revenue surging over 25% compared to Q1 baseline months."

---

### 03:00 – 04:00 | Segment 6: Customer & Product Analysis
**Visual on Screen:** Executing `05_customer_analysis.sql` and `06_product_analysis.sql`.  
**Spoken Narration:**  
> "Moving to customer and product analysis: Our customer queries reveal significant revenue concentration. Top corporate accounts like Vanguard Digital #63 generated over **$2.25 million** in spend. In fact, our Pareto 80/20 analysis proves that corporate resellers account for 68% of enterprise revenue.
> On the product side, our category breakdown shows an interesting margin discrepancy. Laptops & Desktops generated our highest top-line volume—over **$57.4 million**—but carried our lowest margin at **29.22%**. In contrast, Peripherals & Accessories yielded our highest gross margin at **49.31%**, and Storage Solutions delivered **$40.1 million** at a **44.75%** margin. The RAID Storage Expansion Array SKU alone generated **$8.4 million** in gross profit."

---

### 04:00 – 05:00 | Segment 7: Market & Target Analysis
**Visual on Screen:** Executing `08_target_analysis.sql` showing Actual vs Target Variance and Status.  
**Spoken Narration:**  
> "Next, let's examine market target performance. By joining our monthly actual sales against target quotas, we calculate actual sales, target sales, variance, and achievement percentage.
> Overall, the company missed its total global target of $208.5 million by **-$40.8 million**, completing **80.43%** of target. North America West achieved the highest target completion at **92.40%**, whereas expansion markets like APAC Japan achieved only **48.55%** and LATAM Brazil reached only **35.02%**, highlighting severe over-estimation in regional quota planning."

---

### 05:00 – 05:45 | Segment 8: Advanced SQL Demonstration
**Visual on Screen:** Code editor highlighting `09_advanced_analysis.sql` (Multi-step CTE, Window functions, `DENSE_RANK()`, rolling averages).  
**Spoken Narration:**  
> "To handle complex analytical logic cleanly, I authored advanced multi-step CTEs and window functions. 
> For instance, this query computes the top 3 products within every category using `DENSE_RANK() PARTITION BY category`. Another query computes running total cumulative revenue alongside a rolling 3-month moving average using `AVG() OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`. This keeps our query logic modular and highly efficient."

---

### 05:45 – 06:30 | Segment 9: Empirical Business Insights & Recommendations
**Visual on Screen:** Displaying `documentation/business_insights.md` and `documentation/business_recommendations.md`.  
**Spoken Narration:**  
> "Translating these SQL results into business strategy, I formulated five key recommendations:
> First, establish a Platinum VIP Retention Program with dedicated SLAs for the top 20 accounts driving 68% of revenue. 
> Second, launch attach-product bundling—pairing low-margin laptops with high-margin storage and peripherals to expand order gross margin. 
> And third, recalibrate 2026 sales targets downward by 35% in LATAM and APAC Japan, shifting from top-down quotas to bottom-up pipeline forecasting."

---

### 06:30 – 07:00 | Segment 10: GitHub Repository Showcase
**Visual on Screen:** Scrolling through the clean folder structure, `README.md`, `LICENSE`, `.gitignore`, and documentation files on GitHub.  
**Spoken Narration:**  
> "The entire repository is structured for production deployment on GitHub. It includes a complete data dictionary, business questions catalogue, execution instructions, resume highlights, interview preparation guides, and automated Python testing scripts to ensure full reproducibility."

---

### 07:00 – 07:30 | Segment 11: Conclusion
**Visual on Screen:** Final summary slide or camera view.  
**Spoken Narration:**  
> "This project demonstrates my ability to manage the complete analytics lifecycle: from relational database architecture and SQL data cleaning to advanced query optimization and executive business strategy. 
> Thank you for watching! All code and documentation are available on my GitHub repository linked below."
