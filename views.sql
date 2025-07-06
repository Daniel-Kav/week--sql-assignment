-- demonstrate an example of views
-- create a view that shows the total sales for each product
CREATE VIEW IF NOT EXISTS product_sales AS
SELECT
    p.product_name,
    SUM(f.quantity) AS total_quantity_sold
FROM
    fact_sales f
JOIN
    dim_product p ON f.product_id = p.product_id
GROUP BY
    p.product_name;
-- create a view that shows the total sales for each customer
CREATE VIEW IF NOT EXISTS customer_sales AS
SELECT
    c.customer_name,
    SUM(f.quantity) AS total_quantity_sold
FROM
    fact_sales f
JOIN
    dim_customer c ON f.customer_id = c.customer_id
GROUP BY
    c.customer_name;
-- create a view that shows the total sales for each location
CREATE VIEW IF NOT EXISTS location_sales AS
SELECT
    l.location_name,
    SUM(f.quantity) AS total_quantity_sold
FROM
    fact_sales f
JOIN
    dim_location l ON f.location_id = l.location_id
GROUP BY
    l.location_name;
-- create a view that shows the total sales for each date
CREATE VIEW IF NOT EXISTS date_sales AS
SELECT
    d.date_id,
    d.date,
    SUM(f.quantity) AS total_quantity_sold
FROM
    fact_sales f
JOIN
    dim_date d ON f.date_id = d.date_id
GROUP BY
    d.date_id, d.date;
-- create a view that shows the total sales for each product and customer
CREATE VIEW IF NOT EXISTS product_customer_sales AS
SELECT
    p.product_name,
    c.customer_name,
    l.location_name,
    d.date,
    SUM(f.quantity) AS total_quantity_sold
FROM
    fact_sales f
JOIN
    dim_product p ON f.product_id = p.product_id
JOIN
    dim_customer c ON f.customer_id = c.customer_id
JOIN
    dim_location l ON f.location_id = l.location_id
JOIN
    dim_date d ON f.date_id = d.date_id
GROUP BY
    p.product_name,
    c.customer_name,
    l.location_name,
    d.date;
