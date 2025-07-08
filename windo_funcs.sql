-- WINDOW FUNCTIONS
-- demonstrate an example of window functions
-- create a cte that shows the total sales for each product and customer
WITH product_customer_sales AS (
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
        d.date
)
SELECT
    product_name,
    customer_name,
    location_name,
    date,
    total_quantity_sold,
    ROW_NUMBER() OVER (PARTITION BY product_name, customer_name, location_name, date ORDER BY total_quantity_sold DESC) AS row_num,
    RANK() OVER (PARTITION BY product_name, customer_name, location_name, date ORDER BY total_quantity_sold DESC) AS rank_num,
    DENSE_RANK() OVER (PARTITION BY product_name, customer_name, location_name, date ORDER BY total_quantity_sold DESC) AS dense_rank_num,
    NTILE(4) OVER (PARTITION BY product_name, customer_name, location_name, date ORDER BY total_quantity_sold DESC) AS quartile_num
FROM
    product_customer_sales  

--