-- 1 vw_product_seasonality
-- Tracks product performance across time (monthly/quarterly)

CREATE OR REPLACE VIEW vw_product_seasonality AS
SELECT 
    dp.product_id,
    dp.product_name,
    dd.year,
    dd.month,
    dd.quarter,
    SUM(fs.quantity) AS total_quantity,
    SUM(fs.sales) AS total_sales,
    SUM(fs.profit) AS total_profit
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_date dd ON fs.date_id = dd.date_id
GROUP BY dp.product_id, dp.product_name, dd.year, dd.month, dd.quarter;

-- 2 vw_discount_analysis
-- Analyzes relationship between discounts and profitability

CREATE OR REPLACE VIEW vw_discount_impact_analysis AS
SELECT 
    dp.product_id,
    dp.product_name,
    ROUND(AVG(fs.discount), 2) AS avg_discount,
    ROUND(SUM(fs.profit), 2) AS total_profit,
    COUNT(fs.order_id) AS order_count
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
GROUP BY dp.product_id, dp.product_name;

-- 3 vw_customer_order_patterns
-- Analyzes customer order patterns by segment

CREATE OR REPLACE VIEW vw_customer_order_patterns AS
SELECT 
    dc.segment,
    COUNT(DISTINCT fs.order_id) AS order_frequency,
    ROUND(AVG(fs.total_sales), 2) AS avg_order_value,
    ROUND(SUM(fs.profit), 2) AS total_profit
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.segment;

\COPY (SELECT * FROM vw_product_seasonality) TO 'product_seasonality.csv' CSV HEADER;
\COPY (SELECT * FROM vw_discount_impact_analysis) TO 'discount_impact.csv' CSV HEADER;
\COPY (SELECT * FROM vw_customer_order_patterns) TO 'customer_patterns.csv' CSV HEADER;

-- 4 vw_channel_margin_report
-- Compares profitability between online and in-store channels

CREATE OR REPLACE VIEW vw_channel_margin_report AS
SELECT 
    fs.order_mode,
    COUNT(fs.order_id) AS order_count,
    ROUND(SUM(fs.sales), 2) AS total_sales,
    ROUND(SUM(fs.profit), 2) AS total_profit,
    ROUND(AVG(fs.profit), 2) AS avg_profit_per_order
FROM fact_sales fs
GROUP BY fs.order_mode;

-- 5 vw_region_category_rankings
-- Ranks product categories by profit within each region

CREATE OR REPLACE VIEW vw_region_category_rankings AS
SELECT 
    dc.region,
    dp.category,
    ROUND(SUM(fs.profit), 2) AS total_profit,
    RANK() OVER (PARTITION BY dc.region ORDER BY SUM(fs.profit) DESC) AS category_rank
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
JOIN dim_product dp ON fs.product_id = dp.product_id
GROUP BY dc.region, dp.category;

\COPY (SELECT * FROM vw_channel_margin_report) TO 'channel_margin_report.csv' CSV HEADER;
\COPY (SELECT * FROM vw_region_category_rankings) TO 'region_category_rankings.csv' CSV HEADER;

DROP VIEW IF EXISTS vw_product_seasonality;


