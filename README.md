SQL Sales Analysis Project

A complete SQL end-to-end analysis including data cleaning, KPI analysis, time trends, product insights, customer segmentation, and advanced SQL (Window functions + CTEs).

1. Data Cleaning Summary

Performed essential cleaning steps:
Created a working table (Cleaned_data)
Trimmed whitespace from text fields
Standardized missing city names → "Unknown"
Cleaned invalid city entries (Level 3, 33, Floor No. 4 etc.)
Fixed spelling issues (Aaarhus → Aarhus)
Replaced missing state/country with "Unknown" / "Unspecified"
Validated column types with sp_columns

Result:
✔ Data is consistent, cleaned, and ready for analysis.

2. CORE KPI INSIGHTS
Total Sales Revenue — ₹10,032,628.85

Insight:
Revenue is strong and dominated by high-value B2B orders rather than large order volume. The business relies on premium product sales rather than quantity-driven growth.

2️⃣ Total Orders — 307

Insight:
Only 307 orders generated ₹10M+, which confirms high-ticket transactions. This means each customer/order is valuable and retention matters more than volume.

3️⃣ Total Quantity Sold — 99,067 units

Insight:
Good volume efficiency: ~100K units sold across only 307 orders means bulk orders, typical in wholesale or distributor channels.

4️⃣ Average Order Value (AOV) — ₹32,679.57

Insight:
Very high AOV — the business earns ₹32K per order on average. This validates that the company operates in a premium, high-margin category.
   

