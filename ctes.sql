--comprehensive samples of ctes
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
-- create a cte that shows the top 2 students by grade for each student_name
WITH top_students AS (
    SELECT
        student_name,
        grade,
        ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY grade DESC) AS row_num
    FROM
        students
)
SELECT
    student_name,
    grade
FROM
    top_students
WHERE
    row_num <= 2;
-- create a cte that shows the top 2 students by grade for each student_name and student_id
WITH top_students AS (
    SELECT
        student_name,
        student_id,
        grade,
        ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY grade DESC) AS row_num
    FROM
        students
)
SELECT
    student_name,
    student_id,
    grade
FROM
    top_students
WHERE
    row_num <= 2;
-- create a cte that shows the top 2 students by grade for each student_name and student_id and location
WITH top_students AS (
    SELECT
        student_name,
        student_id,
        grade,
        ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY grade DESC) AS row_num
    FROM
        students
)
SELECT
    student_name,
    student_id,
    grade
FROM
    top_students
WHERE
    row_num <= 2
    AND student_name = 'John'
    AND student_id = 1;
-- create a cte that shows the top 2 students by grade for each student_name and student_id and location and date
WITH top_students AS (
    SELECT
        student_name,
        student_id,
        grade,
        ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY grade DESC) AS row_num
    FROM
        students
)
SELECT
    student_name,
    student_id,
    grade
FROM
    top_students
WHERE
    row_num <= 2        
    AND student_name = 'John'
    AND student_id = 1;

    -- create a cte that shows the top 2 students by grade for each student_name and student_id and location and date and product
WITH top_students AS (
    SELECT
        student_name,
        student_id,
        grade,
        ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY grade DESC) AS row_num
    FROM
        students
)
SELECT
    student_name,
    student_id,
    grade
FROM
    top_students
WHERE
    row_num <= 2        
    AND student_name = 'John'
    AND student_id = 1
    AND location = 'NY'
    AND product = 'Math';

