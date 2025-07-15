-- ====================================================
-- ACE Superstore | Strategic Insight Query Library
-- Description: Five reusable SQL queries joining fact 
-- and dimension tables for business analysis.
-- ====================================================

-- 1. Monthly Sales Trends by Product Category
-- Purpose: Identify seasonal sales patterns across categories.
SELECT 
    dd.year,
    dd.month,
    dp.category,
    ROUND(SUM(fs.sales), 2) AS monthly_sales
FROM fact_sales fs
JOIN dim_date dd ON fs.date_id = dd.date_id
JOIN dim_product dp ON fs.product_id = dp.product_id
GROUP BY dd.year, dd.month, dp.category
ORDER BY dd.year, dd.month, monthly_sales DESC;

-- 2. Top Regions by Total Profit
-- Purpose: Highlight regions generating the highest profitability.
SELECT 
    dc.region,
    ROUND(SUM(fs.profit), 2) AS region_profit
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.region
ORDER BY region_profit DESC;

-- 3. Average Order Value by Customer Segment
-- Purpose: Understand value per transaction across customer groups.
SELECT 
    dc.segment,
    ROUND(AVG(fs.total_sales), 2) AS avg_order_value
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.segment
ORDER BY avg_order_value DESC;

-- 4. Profit Contribution by Order Mode
-- Purpose: Evaluate performance of sales channels (e.g., online vs. in-store).
SELECT 
    fs.order_mode,
    COUNT(fs.order_id) AS order_count,
    ROUND(SUM(fs.profit), 2) AS total_profit,
    ROUND(AVG(fs.profit), 2) AS avg_profit_per_order
FROM fact_sales fs
GROUP BY fs.order_mode
ORDER BY total_profit DESC;

-- 5. Most Profitable Products by Region
-- Purpose: Surface high-margin products regionally for targeted promotion.
SELECT 
    dc.region,
    dp.product_name,
    ROUND(SUM(fs.profit), 2) AS product_profit
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.region, dp.product_name
ORDER BY dc.region, product_profit DESC;
