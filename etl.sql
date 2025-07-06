-- end to end qa workflow
-- step 1:  generate a list of all the tables in the database
-- step 2:  for each table, check for missing values
-- step 3:  for each table, check the data types
-- step 4:  for each table, check for outliers
-- step 5:  for each table, check for duplicates
-- step 6:  for each table, check for consistency
-- step 7:  for each table, check for accuracy
-- step 8:  for each table, check for completeness
-- step 9:  for each table, check for integrity
-- step 10:  for each table, check for security

 -- tables to be contained in the db
CREATE TABLE IF NOT EXISTS dim_date (
    date_id DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    week INT,
    day_of_week INT,
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_location (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sales_id INT PRIMARY KEY,
    date_id DATE,
    location_id INT,
    customer_id INT,
    product_name VARCHAR(255),
    quantity INT,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    FOREIGN KEY (date_id) REFERENCES dim_date (date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location (location_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer (customer_id)
);

CREATE TABLE IF NOT EXISTS fact_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (product_name) REFERENCES dim_product (product_name)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (product_id) REFERENCES fact_product (product_id)
);

-- CHECK FOR NULL VALUES

SELECT COUNT(*)
FROM dim_date
WHERE date_id IS NULL;

SELECT COUNT(*)
FROM dim_location
WHERE location_id IS NULL;

SELECT COUNT(*)
FROM dim_customer
WHERE customer_id IS NULL;

SELECT COUNT(*)
FROM fact_sales
WHERE sales_id IS NULL;

SELECT COUNT(*)
FROM fact_product
WHERE product_id IS NULL;

SELECT COUNT(*)
FROM dim_product
WHERE product_id IS NULL;

-- CHECK FOR DUPLICATE VALUES

SELECT COUNT(*)
FROM dim_date
WHERE date_id IS NULL;

SELECT COUNT(*)
FROM dim_location
WHERE location_id IS NULL;

SELECT COUNT(*)
FROM dim_customer
WHERE customer_id IS NULL;

SELECT COUNT(*)
FROM fact_sales
WHERE sales_id IS NULL;

SELECT COUNT(*)
FROM fact_product
WHERE product_id IS NULL;

SELECT COUNT(*)
FROM dim_product
WHERE product_id IS NULL;

-- CHECK DATA TYPES

SELECT 
    column_name, 
    data_type, 
    character_maximum_length
FROM 
    information_schema.columns
WHERE 
    table_name = 'dim_date';    
    

SELECT 
    column_name, 
    data_type, 
    character_maximum_length
FROM 
    information_schema.columns
WHERE 
    table_name = 'dim_location';    

