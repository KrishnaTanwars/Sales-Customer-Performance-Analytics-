# Project Description — Sales & Customer Performance Analytics | SQL

This document provides a clean, professional summary suitable for posting on LinkedIn, GitHub repository releases, or personal portfolio websites.

---

## Short Description (LinkedIn / Portfolio Highlight)

**Sales & Customer Performance Analytics | SQL Portfolio Project**

An end-to-end, production-grade SQL analytics project built on **MySQL 8+** analyzing over **105,000 sales transactions** ($167.69M total revenue) across 10 global markets, 150 corporate accounts, and 50 hardware products from 2023 to 2025.

### Key Highlights:
- **Relational Schema & Views:** Designed a 3NF relational database schema with Primary/Foreign Keys, composite indexes, constraint enforcement, and 5 analytical views.
- **Advanced Analytical SQL:** Authored 30+ queries utilizing multi-step CTEs, window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, `SUM/AVG OVER`), subqueries, and running totals.
- **Commercial Performance Evaluation:** Uncovered a -$40.80M target-to-actual variance across international markets, identified top-performing customer tiers, and revealed product margin discrepancies between Laptops (29.22% GM) and Storage/Peripherals (44.75%–49.31% GM).
- **Executive Strategy:** Provided data-driven recommendations to restructure regional sales quotas, launch attach-product cross-selling programs, and protect VIP corporate reseller accounts.

---

## Detailed GitHub Release Notes / Repository Bio

The **Sales & Customer Performance Analytics** project transforms raw transaction logs into actionable business intelligence using MySQL 8+. 

### Technical Architecture:
1. **Schema & Normalization:** `01_database_schema.sql` establishes 5 core tables (`markets`, `customers`, `products`, `targets`, `sales_transactions`) with strict data integrity rules.
2. **Data Pipeline & Auditing:** `02_data_loading.sql` & `03_data_quality.sql` ensure clean data ingestion, checking row counts, duplicate transaction IDs, orphan foreign keys, and date/numeric sanity.
3. **Core & Advanced SQL Analysis:** `04_sales_analysis.sql` through `09_advanced_analysis.sql` address 25+ business questions covering revenue trends, customer lifetime value, category contribution %, target achievement, and MoM growth trajectories.
4. **Business Intelligence Deliverables:** Complete data dictionary, empirical insights, strategic recommendations, screen recording presentation script, and interview preparation guide.

### Core Metrics Summary:
- **Total Revenue:** $167,693,927.24
- **Total Gross Profit:** $66,641,864.24 (39.74% Gross Margin)
- **Top Product Category:** Laptops & Desktops ($57.43M revenue, 34.24% share)
- **Top Profit SKU:** RAID Storage Expansion Array (PROD_037 - $8.40M gross profit)
- **Target Achievement Rate:** 80.43% ($167.69M actual vs $208.50M quota)
