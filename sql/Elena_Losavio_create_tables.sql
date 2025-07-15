-- ==========================================
-- ACE Superstore Star Schema Build Script
-- ==========================================

-- 🔹 Drop Tables If They Already Exist
DROP TABLE IF EXISTS fact_sales, staging_fact_sales;
DROP TABLE IF EXISTS dim_product, dim_customer, dim_order_mode, dim_date;

-- ==========================================
-- Create Dimension Tables
-- ==========================================

CREATE TABLE dim_product (
    product_id TEXT PRIMARY KEY,
    category TEXT,
    sub_category TEXT,
    product_name TEXT
);

CREATE TABLE dim_customer (
    customer_id TEXT PRIMARY KEY,
    city TEXT,
    postcode TEXT,
    region TEXT,
    country TEXT,
    segment TEXT
);

CREATE TABLE dim_order_mode (
    order_mode TEXT PRIMARY KEY
);

CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY,
    order_date DATE UNIQUE,
    year INTEGER,
    month INTEGER,
    quarter TEXT
);

-- ==========================================
-- Load Dimension Data from CSVs
-- ==========================================

-- Replace file paths with actual locations on your machine
\copy dim_product(product_id, category, sub_category, product_name)
FROM '/Users/elena/Bootcamp/star_schema_exports/Elena_Losavio_dim_product.csv'
DELIMITER ',' CSV HEADER;

\copy dim_customer(customer_id, city, postcode, region, country, segment)
FROM '/Users/elena/Bootcamp/star_schema_exports/Elena_Losavio_dim_customer.csv'
DELIMITER ',' CSV HEADER;

\copy dim_order_mode(order_mode)
FROM '/Users/elena/Bootcamp/star_schema_exports/Elena_Losavio_dim_order_mode.csv'
DELIMITER ',' CSV HEADER;

\copy staging_dim_date(order_date, year, month, quarter)
FROM '/Users/elena/Bootcamp/star_schema_exports/Elena_Losavio_dim_date.csv'
DELIMITER ',' CSV HEADER;

-- Insert unique dates into dim_date with surrogate key
INSERT INTO dim_date(date_id, order_date, year, month, quarter)
SELECT 
    EXTRACT(YEAR FROM order_date)::INTEGER * 10000 +
    EXTRACT(MONTH FROM order_date)::INTEGER * 100 +
    EXTRACT(DAY FROM order_date)::INTEGER AS date_id,
    order_date, year, month, quarter
FROM staging_dim_date
ON CONFLICT (order_date) DO NOTHING;

-- ==========================================
-- Create Staging and Fact Tables
-- ==========================================

CREATE TABLE staging_fact_sales (
    order_id TEXT,
    customer_id TEXT,
    product_id TEXT,
    order_date DATE,
    order_mode TEXT,
    quantity INTEGER,
    discount NUMERIC,
    sales NUMERIC,
    cost_price NUMERIC,
    total_sales NUMERIC,
    total_costs NUMERIC,
    profit NUMERIC,
    discount_amount NUMERIC
);

CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    order_id TEXT,
    customer_id TEXT REFERENCES dim_customer(customer_id),
    product_id TEXT REFERENCES dim_product(product_id),
    date_id INTEGER REFERENCES dim_date(date_id),
    order_mode TEXT REFERENCES dim_order_mode(order_mode),
    quantity INTEGER,
    discount NUMERIC,
    sales NUMERIC,
    cost_price NUMERIC,
    total_sales NUMERIC,
    total_costs NUMERIC,
    profit NUMERIC,
    discount_amount NUMERIC
);

-- ==========================================
-- Load and Clean Fact Sales Data
-- ==========================================

-- Ensure CSV values are cleaned (no commas in numeric fields)
\copy staging_fact_sales(order_id, customer_id, product_id, order_date, order_mode,
                         quantity, discount, sales, cost_price,
                         total_sales, total_costs, profit, discount_amount)
FROM '/Users/elena/Bootcamp/star_schema_exports/Elena_Losavio_fact_sales.csv'
DELIMITER ',' CSV HEADER;

-- Insert only valid FK-matching rows, with joined date_id
INSERT INTO fact_sales(order_id, customer_id, product_id, date_id, order_mode,
                       quantity, discount, sales, cost_price,
                       total_sales, total_costs, profit, discount_amount)
SELECT 
    fs.order_id, fs.customer_id, fs.product_id, d.date_id, fs.order_mode,
    fs.quantity, fs.discount, fs.sales, fs.cost_price,
    fs.total_sales, fs.total_costs, fs.profit, fs.discount_amount
FROM staging_fact_sales fs
JOIN dim_date d ON fs.order_date = d.order_date
WHERE fs.customer_id IN (SELECT customer_id FROM dim_customer)
  AND fs.product_id IN (SELECT product_id FROM dim_product)
  AND fs.order_mode IN (SELECT order_mode FROM dim_order_mode);

