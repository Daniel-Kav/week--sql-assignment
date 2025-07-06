-- demonstrate the difference between RANK() and DENSE_RANK with an example 
-- create a sample table
CREATE TABLE IF NOT EXISTS sales (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    sale_date DATE,
    sale_amount DECIMAL(10, 2)
);

-- insert sample data
INSERT INTO sales (sale_id, product_name, sale_date, sale_amount)
VALUES
    (1, 'Product A', '2023-01-01', 100.00),
    (2, 'Product B', '2023-01-02', 150.00),
    (3, 'Product A', '2023-01-03', 120.00),
    (4, 'Product C', '2023-01-04', 90.00),
    (5, 'Product B', '2023-01-05', 180.00);

-- rank() and dense_rank() example
SELECT
    sale_id,
    product_name,
    sale_date,
    sale_amount,
    RANK() OVER (PARTITION BY product_name ORDER BY sale_amount) AS sale_rank,
    DENSE_RANK() OVER (PARTITION BY product_name ORDER BY sale_amount) AS dense_rank
FROM
    sales;
-- rank() and dense_rank() explanation
-- rank() assigns a rank to each row within a partition based on the order of the specified column
-- dense_rank() also assigns a rank but it doesn't skip any ranks if there are gaps in the data
-- in the example above, you can see that for product A, the dense_rank() assigns 1 to the first row and 2 to the second row,
-- while rank() assigns 1 to both rows because they have the same sale_amount within the partition
-- for product B, dense_rank() assigns 1 to the first row and 2 to the second row,
-- while rank() assigns 1 to the first row and 3 to the second row because the sale_amount for product B is higher than for product A
-- for product C, dense_rank() assigns 1 to the first row and 2 to the second row,
-- while rank() assigns 1 to the first row and 2 to the second row because they have the same sale_amount within the partition
