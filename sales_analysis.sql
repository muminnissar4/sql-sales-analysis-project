-- ===========================================================
-- SQL SALES ANALYSIS PROJECT | CLEANING + ANALYSIS + INSIGHTS
-- ===========================================================

--------------------------------------------------------------
-- 0) DATA CLEANING
--------------------------------------------------------------
select * from sales_data ---INFO

EXEC sp_columns SALES_DATA  --- CHECKING DATA TYPES

	SELECT
		ORDERNUMBER, ORDERLINENUMBER, QUANTITYORDERED, PRICEEACH, SALES,
	    ORDERDATE, STATUS, QTR_ID, MONTH_ID, YEAR_ID,
	    PRODUCTLINE, PRODUCTCODE, MSRP,
		CUSTOMERNAME, CITY, STATE, COUNTRY, TERRITORY
Into Cleaned_data
FROM sales_data;

select * from Cleaned_data

-- STEP 1 — CHECK the cleaned table
SELECT TOP 20 * FROM Cleaned_data

 --step 2 TRIM WHITESPACES (if any)
 UPDATE Cleaned_data
SET 
    STATUS = LTRIM(RTRIM(STATUS)),
    PRODUCTLINE = LTRIM(RTRIM(PRODUCTLINE)),
    PRODUCTCODE = LTRIM(RTRIM(PRODUCTCODE)),
    CUSTOMERNAME = LTRIM(RTRIM(CUSTOMERNAME)),
    CITY = LTRIM(RTRIM(CITY)),
    STATE = LTRIM(RTRIM(STATE)),
    COUNTRY = LTRIM(RTRIM(COUNTRY)),
    TERRITORY = LTRIM(RTRIM(TERRITORY));

--FIX ‘Unknown’ VALUES
UPDATE Cleaned_data
SET CITY = 'Unknown'
WHERE CITY = '' OR CITY IS NULL;

-- Clean Bad City Labels
UPDATE Cleaned_data
SET CITY = 'Unknown'
WHERE CITY IN (
    'Level 3', 'Level 6', 'Level 15', 'Floor No. 4',
    '33', '67', 'PB 744 Sentrum', 'boulevard Charonne',
    'rue du Commerce', 'Bronz Apt. 3/6 Tesvikiye'
);


-- SPELLING 
UPDATE Cleaned_data
SET CITY = 'Aarhus'
WHERE CITY = 'Aaarhus';

UPDATE Cleaned_data
SET STATE = 'Unknown'
WHERE STATE = '' OR STATE IS NULL;

EXEC sp_columns Cleaned_data

-- CHECKING COUNTRY
SELECT 
	DISTINCT(COUNTRY)
FROM Cleaned_data


UPDATE Cleaned_data
SET COUNTRY = 'Unspecified / Missing Data'
WHERE COUNTRY IN ('Unknown', 'B-6000');


--------------------------------------------------------------
-- 1) CORE KPIs
--------------------------------------------------------------
--sales performance 

SELECT * FROM Cleaned_data
--1) total sales
	
SELECT 
	SUM(SALES) AS TotaL_Sales
FROM Cleaned_data

--2) total orders
	
SELECT 
	COUNT(DISTINCT(ORDERNUMBER)) AS TotaL_order
FROM Cleaned_data

--3) total quantity sold
	
SELECT 
	SUM(QUANTITYORDERED) AS TotaL_QTY
FROM Cleaned_data

--4 Average Order Value (AOV)
SELECT 
	CAST(ROUND(SUM(SALES) / COUNT(DISTINCT(ORDERNUMBER)) ,2) AS FLOAT) AOV
FROM Cleaned_data

--5) Revenue by Product Line
SELECT 
	PRODUCTLINE,
	SUM(SALES) AS TOTAL_REVENUE
FROM Cleaned_data
GROUP BY PRODUCTLINE
ORDER BY TOTAL_REVENUE DESC



--------------------------------------------------------------
-- 2) TIME ANALYSIS
--------------------------------------------------------------
						 SELECT * FROM Cleaned_data
--1) Sales by Month
SELECT 
    MONTH_ID AS month_number,
    SUM(SALES) AS total_sales
FROM Cleaned_data
GROUP BY MONTH_ID
ORDER BY MONTH_ID;


--2) Sales by Quarter
SELECT 
	QTR_ID,
	SUM(SALES) AS TOTAL_SALES 
FROM Cleaned_data
GROUP BY QTR_ID
ORDER BY  QTR_ID


--3) Sales by Year
SELECT 
	YEAR_ID,
	SUM(SALES) AS TOTAL_SALES 
FROM Cleaned_data
GROUP BY YEAR_ID
ORDER BY YEAR_ID

--4) Highest Sales Month
 --Find the max month based on monthly revenue.

SELECT TOP 1
	YEAR_ID,
	MONTH_ID,
	SUM(SALES) AS TOTAL_SALES
FROM Cleaned_data
GROUP BY YEAR_ID,MONTH_ID
ORDER BY TOTAL_SALES DESC


--------------------------------------------------------------
-- 3) PRODUCT ANALYSIS
--------------------------------------------------------------
								  SELECT * FROM Cleaned_data
--1) Top Products by Revenue
SELECT
	PRODUCTCODE,
	SUM(SALES) AS TOTAL_SALES
FROM Cleaned_data
GROUP BY PRODUCTCODE
ORDER BY SUM(SALES)  DESC

--2) Product Line with Most Units Sold
SELECT
	PRODUCTLINE,
	SUM(QUANTITYORDERED) AS TOTAL_QUANTITY_SOLD
FROM Cleaned_data
GROUP BY PRODUCTLINE
ORDER BY SUM(QUANTITYORDERED)DESC

 --3) Product Line with Highest Average Price
 SELECT 
	PRODUCTLINE,
	AVG(PRICEEACH) AS AVG_PRICE
FROM Cleaned_data
group by PRODUCTLINE
order by AVG_PRICE desc


--4) Top 5 Products by Quantity Sold
SELECT TOP 5
	PRODUCTLINE,
	SUM(QUANTITYORDERED) AS TOTAL_QUANTITY_SOLD
FROM Cleaned_data
GROUP BY PRODUCTLINE
ORDER BY PRODUCTLINE DESC

--5) Product Profit Potential (MSRP vs PriceEach)
SELECT 
    PRODUCTCODE,
    PRODUCTLINE,
    MSRP,
   CAST( ROUND(AVG(PRICEEACH),2) AS DECIMAL(10,0)) AS avg_selling_price,
    (MSRP -CAST( ROUND(AVG(PRICEEACH),2) AS DECIMAL(10,0)))  AS profit_potential
FROM Cleaned_data
GROUP BY PRODUCTCODE, PRODUCTLINE, MSRP
ORDER BY profit_potential DESC;




--------------------------------------------------------------
-- 4) CUSTOMER ANALYSIS
--------------------------------------------------------------
                             
								 SELECT * FROM Cleaned_data
--1) Top 10 Customers by Revenue
SELECT TOP 10 
	CUSTOMERNAME,
	SUM(SALES) AS TOTAL_SALES
FROM Cleaned_data
GROUP BY CUSTOMERNAME
ORDER BY TOTAL_SALES DESC

--2) Repeat Customers
SELECT 
    CUSTOMERNAME,
    COUNT(DISTINCT ORDERNUMBER) AS total_orders
FROM Cleaned_data
GROUP BY CUSTOMERNAME
HAVING COUNT(DISTINCT ORDERNUMBER) >= 2
ORDER BY total_orders DESC;

--3) Average Revenue Per Customer

SELECT 
    CAST(ROUND(SUM(SALES) / COUNT(DISTINCT CUSTOMERNAME), 2) AS DECIMAL(10,2)) AS avg_revenue_per_customer
FROM Cleaned_data;


-- 4) Sales by Country
SELECT
	COUNTRY,
	SUM(SALES) AS TOTAL_SALES
FROM Cleaned_data
GROUP BY COUNTRY
ORDER BY TOTAL_SALES DESC

--5) Top 5 Cities by Revenue
SELECT 
    CITY,
    SUM(SALES) AS total_revenue
FROM Cleaned_data
GROUP BY CITY
ORDER BY total_revenue DESC;



--------------------------------------------------------------
-- 5) ADVANCED SQL (WINDOW + CTE)
--------------------------------------------------------------                                        
											 SELECT * FROM Cleaned_data
--1) Top Product Inside Each Product Line
  --( Goal: Find the highest-revenue product in every product line.)
 SELECT 
    PRODUCTLINE,
    PRODUCTCODE,
    TOTAL_REVENUE
FROM (
    SELECT 
        PRODUCTLINE,
        PRODUCTCODE,
        SUM(SALES) AS TOTAL_REVENUE,
        RANK() OVER (PARTITION BY PRODUCTLINE ORDER BY SUM(SALES) DESC) product_rank
    FROM Cleaned_data
    GROUP BY PRODUCTLINE, PRODUCTCODE
) RANKED
WHERE product_rank = 1
ORDER BY TOTAL_REVENUE DESC;


--2) 2. Rank Customers by Total Revenue
SELECT
    CUSTOMERNAME,
    SUM(SALES) AS TOTAL_REVENUE,
    RANK() OVER (ORDER BY SUM(SALES) DESC) AS revenue_rank
FROM Cleaned_data
GROUP BY CUSTOMERNAME
ORDER BY TOTAL_REVENUE DESC;


--3) 3. Running Total of Monthly Sales
---Goal: Show cumulative revenue growth month by month.
WITH MONTHLY_SALES AS (
    SELECT
        YEAR_ID,
        MONTH_ID,
        SUM(SALES) AS TOTAL_SALES
    FROM Cleaned_data
    GROUP BY YEAR_ID, MONTH_ID
)
SELECT 
    YEAR_ID,
    MONTH_ID,
    SUM(TOTAL_SALES) OVER (ORDER BY YEAR_ID, MONTH_ID) AS RUNNING_TOTAL
FROM MONTHLY_SALES
ORDER BY YEAR_ID, MONTH_ID;


--4) Year-over-Year Revenue Growth
---Goal: Compare sales growth between consecutive years.
WITH YoY_revenue AS (
    SELECT
        YEAR_ID,
        SUM(SALES) AS TOTAL_SALES
    FROM Cleaned_data
    GROUP BY YEAR_ID
)
SELECT 
    YEAR_ID,
    TOTAL_SALES,
    LAG(TOTAL_SALES) OVER (ORDER BY YEAR_ID) AS prev_year_sales,
    CAST(
        ROUND(
            (TOTAL_SALES - LAG(TOTAL_SALES) OVER (ORDER BY YEAR_ID)) / 
            NULLIF(LAG(TOTAL_SALES) OVER (ORDER BY YEAR_ID), 0) * 100, 2
        ) AS DECIMAL(10,2)
    ) AS yoy_growth_percent
FROM YoY_revenue
ORDER BY YEAR_ID;


--5) 3-Month Moving Average of Sales
-- Goal: Smooth short-term fluctuations to reveal the sales trend.
WITH MonthlySales AS (
    SELECT
        YEAR_ID,
        MONTH_ID,
        SUM(SALES) AS TOTAL_SALES
    FROM Cleaned_data
    GROUP BY YEAR_ID, MONTH_ID
)
SELECT
    YEAR_ID,
    MONTH_ID,
    TOTAL_SALES,
    CAST(
        ROUND(
            AVG(TOTAL_SALES) OVER (ORDER BY YEAR_ID, MONTH_ID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2
        ) AS DECIMAL(10,2)
    ) AS three_month_moving_avg
FROM MonthlySales
ORDER BY YEAR_ID, MONTH_ID;



--------------------------------------------------------------
-- 6) ADDITIONAL ANALYSIS 
--------------------------------------------------------------

-- 1. Order Status Distribution
SELECT 
    STATUS,
    COUNT(DISTINCT ORDERNUMBER) as order_count,
    SUM(SALES) as total_revenue
FROM Cleaned_data
GROUP BY STATUS
ORDER BY total_revenue DESC;

-- 2. Deal Size Segmentation
SELECT 
    CASE 
        WHEN SALES < 2000 THEN 'Small Deal'
        WHEN SALES BETWEEN 2000 AND 5000 THEN 'Medium Deal'
        ELSE 'Large Deal'
    END AS deal_size,
    COUNT(*) as number_of_orders,
    SUM(SALES) as total_revenue
FROM Cleaned_data
GROUP BY CASE 
    WHEN SALES < 2000 THEN 'Small Deal'
    WHEN SALES BETWEEN 2000 AND 5000 THEN 'Medium Deal'
    ELSE 'Large Deal'
END
ORDER BY total_revenue DESC;



