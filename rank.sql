-- demonstrate the difference between RANK() and DENSE_RANK with an example 
-- create a sample table
CREATE TABLE IF NOT EXISTS students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(255),
    grade DECIMAL(3, 2)
);

-- insert sample data
INSERT INTO students (student_id, student_name, grade)
VALUES
    (1, 'John', 90.00),
    (2, 'Emily', 85.00),
    (3, 'John', 92.00),
    (4, 'Emily', 88.00),
    (5, 'John', 95.00),
    (6, 'Emily', 90.00);

-- rank() and dense_rank() example
SELECT
    student_id,
    student_name,
    grade,
    RANK() OVER (PARTITION BY student_name ORDER BY grade DESC) AS rank,
    DENSE_RANK() OVER (PARTITION BY student_name ORDER BY grade DESC) AS dense_rank
FROM
    students
ORDER BY
    student_name, grade DESC;

-- rank() and dense_rank() explanation
-- rank() assigns a rank to each row within a partition based on the order of the specified column
-- dense_rank() also assigns a rank but it doesn't skip any ranks if there are gaps in the data
-- in the example above, you can see that for student_name 'John', the dense_rank() assigns 1 to the first row and 2 to the second row,
-- while rank() assigns 1 to both rows because they have the same grade within the partition
-- for student_name 'Emily', dense_rank() assigns 1 to the first row and 2 to the second row,
-- while rank() assigns 1 to the first row and 3 to the second row because the grade for student_name 'Emily' is higher than for student_name 'John'
-- for student_name 'John', dense_rank() assigns 1 to the first row and 2 to the second row,
-- while rank() assigns 1 to the first row and 2 to the second row because they have the same grade within the partition
