# Business Questions Directory — Sales & Customer Performance Analytics

This document catalogues 25+ business questions addressed by this SQL project, organized by analytical domain.

---

## 1. Sales Performance Analysis
1. **Total Revenue & Volume:** What is total sales revenue, total cost, gross profit, and overall gross margin percentage across the 3-year period?
2. **Monthly Trends:** What is the month-by-month sales revenue and gross profit trend from January 2023 to December 2025?
3. **Yearly Trajectory:** How does yearly revenue compare across 2023, 2024, and 2025?
4. **Month-over-Month Growth:** What is the MoM percentage growth rate in revenue?
5. **Cumulative Sales:** What is the cumulative running total revenue across time?
6. **Peak & Trough Months:** Which calendar months consistently generate the highest and lowest sales revenue?

---

## 2. Customer Performance Analysis
7. **Top Revenue Accounts:** Who are the top 10 customers by total sales revenue?
8. **Top Profit Accounts:** Who are the top 10 customers by total gross profit contribution?
9. **Order Frequency & Volume:** How many orders has each customer placed, and what is their average order volume?
10. **Average Order Value (AOV):** What is the Average Order Value (AOV) per customer across different sales channels?
11. **Repeat Customer Behavior:** How do repeat corporate buyers perform compared to single-order clients?
12. **Revenue Concentration:** What percentage of total company revenue is contributed by top corporate clients?
13. **Above-Average Accounts:** Which customer accounts generate spend above the overall company customer average?
14. **Customer Ranking:** How do customers rank nationally and regionally when ranked by revenue vs. profit?
15. **Customer Value Tiering:** How can customers be segmented into Platinum, Gold, Silver, and Bronze tiers based on revenue quartiles?

---

## 3. Product Performance Analysis
16. **Top Selling Products:** What are the top 10 revenue-generating products in the catalog?
17. **Top Profitable Products:** Which 10 products deliver the highest gross profit margin?
18. **Category Contribution:** What is the revenue, cost, profit, and gross margin % for each product category (`Laptops & Desktops`, `Storage Solutions`, `Networking & Servers`, `Peripherals & Accessories`, `Smart Office`)?
19. **Low-Performing Products:** Which products generate bottom-tier sales revenue or suffer from low gross margin?
20. **Category Leaders:** What are the top 3 products within each product category using window ranking functions (`ROW_NUMBER()` / `DENSE_RANK()`)?
21. **Outperforming Catalog Items:** Which products achieve gross margin percentages above their respective category average?
22. **YoY Product Dynamics:** Which products showed declining performance between 2024 and 2025?

---

## 4. Market Performance Analysis
23. **Market Revenue Ranking:** What is the total revenue, profit, and gross margin % for each of the 10 geographical markets?
24. **Zone Performance:** How do regional zones (`North America`, `Europe`, `Asia Pacific`, `Middle East`, `Latin America`) compare in overall revenue contribution?
25. **Top & Bottom Markets:** Which markets represent the top 3 and bottom 3 revenue performers?
26. **Market Benchmark:** Which markets exceed or fall below the average market revenue baseline?

---

## 5. Target vs. Actual Performance Analysis
27. **Target Achievement %:** What is the actual sales vs. target sales variance for each market?
28. **Target Status:** Which markets achieved their annual target (Status = `Target Achieved`) vs. missed (Status = `Target Missed`)?
29. **Extreme Variances:** Which market suffered the largest negative sales variance, and which achieved the highest positive variance?

---

## 6. Advanced Analytical Patterns
30. **Lead & Lag Analysis:** How do monthly revenue shifts compare when analyzing prior month (`LAG`) and next month (`LEAD`) values alongside rolling 3-month moving averages?
31. **Pareto 80/20 Analysis:** Which specific top customer accounts account for the first 80% of total company revenue?
32. **Cohort Tenure & Frequency:** What is the customer tenure in days, average days between repeat orders, and cohort lifecycle categorization?
