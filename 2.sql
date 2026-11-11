
-- ============================================================
-- WEEK 7 ASSIGNMENT: DATABASE DESIGN AND NORMALIZATION
-- Student: Ahmed
-- Database: week7_normalization
-- Environment: PostgreSQL / pgAdmin 4
-- ============================================================

-- ============================================================
-- QUESTION 1: FIRST NORMAL FORM (1NF)
-- ============================================================

-- 1. Create an unnormalized table

DROP TABLE IF EXISTS student_courses_unnormalized CASCADE;
DROP TABLE IF EXISTS student_courses_1nf CASCADE;
DROP TABLE IF EXISTS students_1nf CASCADE;

CREATE TABLE student_courses_unnormalized (
    student_id INT,
    student_name VARCHAR(100),
    courses TEXT
);

INSERT INTO student_courses_unnormalized
VALUES
(1, 'Ahmed', 'Database, Mathematics'),
(2, 'John', 'Programming, Networking'),
(3, 'Mary', 'Database, Programming');

-- 2. Convert the table into First Normal Form (1NF).
-- Each column must contain a single atomic value.
-- Each student can have multiple course records.

CREATE TABLE students_1nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

CREATE TABLE student_courses_1nf (
    student_id INT,
    course_name VARCHAR(100),
    PRIMARY KEY (student_id, course_name),
    FOREIGN KEY (student_id)
        REFERENCES students_1nf(student_id)
);

-- Insert student information

INSERT INTO students_1nf VALUES
(1, 'Ahmed'),
(2, 'John'),
(3, 'Mary');

-- Insert individual course records

INSERT INTO student_courses_1nf VALUES
(1, 'Database'),
(1, 'Mathematics'),
(2, 'Programming'),
(2, 'Networking'),
(3, 'Database'),
(3, 'Programming');

-- Display First Normal Form results

SELECT
    s.student_id,
    s.student_name,
    c.course_name
FROM students_1nf s
JOIN student_courses_1nf c
ON s.student_id = c.student_id
ORDER BY s.student_id;


-- ============================================================
-- QUESTION 2: SECOND NORMAL FORM (2NF)
-- ============================================================

-- 1. Create a table with partial dependencies.
-- The composite primary key is student_id + course_id.
-- student_name depends only on student_id.
-- course_name depends only on course_id.

DROP TABLE IF EXISTS enrollments_unnormalized CASCADE;
DROP TABLE IF EXISTS enrollments_2nf CASCADE;
DROP TABLE IF EXISTS students_2nf CASCADE;
DROP TABLE IF EXISTS courses_2nf CASCADE;

CREATE TABLE enrollments_unnormalized (
    student_id INT,
    course_id INT,
    student_name VARCHAR(100),
    course_name VARCHAR(100),
    grade VARCHAR(5),
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO enrollments_unnormalized VALUES
(1, 101, 'Ahmed', 'Database', 'A'),
(1, 102, 'Ahmed', 'Mathematics', 'B'),
(2, 101, 'John', 'Database', 'A'),
(2, 103, 'John', 'Networking', 'B'),
(3, 102, 'Mary', 'Mathematics', 'A');

-- 2. Convert into Second Normal Form (2NF).
-- Remove partial dependencies by separating the tables.

CREATE TABLE students_2nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses_2nf (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);

CREATE TABLE enrollments_2nf (
    student_id INT,
    course_id INT,
    grade VARCHAR(5),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id)
        REFERENCES students_2nf(student_id),
    FOREIGN KEY (course_id)
        REFERENCES courses_2nf(course_id)
);

-- Insert student records

INSERT INTO students_2nf VALUES
(1, 'Ahmed'),
(2, 'John'),
(3, 'Mary');

-- Insert course records

INSERT INTO courses_2nf VALUES
(101, 'Database'),
(102, 'Mathematics'),
(103, 'Networking');

-- Insert enrollment records

INSERT INTO enrollments_2nf VALUES
(1, 101, 'A'),
(1, 102, 'B'),
(2, 101, 'A'),
(2, 103, 'B'),
(3, 102, 'A');

-- Display Second Normal Form results

SELECT
    s.student_id,
    s.student_name,
    c.course_id,
    c.course_name,
    e.grade
FROM enrollments_2nf e
JOIN students_2nf s
    ON e.student_id = s.student_id
JOIN courses_2nf c
    ON e.course_id = c.course_id
ORDER BY s.student_id;


-- ============================================================
-- QUESTION 3: THIRD NORMAL FORM (3NF)
-- ============================================================

-- 1. Create a table with a transitive dependency.
-- department_name depends on department_id.
-- department_id is associated with student_id.

DROP TABLE IF EXISTS student_details_unnormalized CASCADE;
DROP TABLE IF EXISTS student_details_3nf CASCADE;
DROP TABLE IF EXISTS departments_3nf CASCADE;
DROP TABLE IF EXISTS students_3nf CASCADE;

CREATE TABLE student_details_unnormalized (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100)
);

INSERT INTO student_details_unnormalized VALUES
(1, 'Ahmed', 10, 'Electrical Engineering'),
(2, 'John', 20, 'Computer Science'),
(3, 'Mary', 10, 'Electrical Engineering');

-- 2. Convert into Third Normal Form (3NF).
-- Remove transitive dependencies by separating departments.

CREATE TABLE departments_3nf (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE students_3nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES departments_3nf(department_id)
);

-- Insert department records

INSERT INTO departments_3nf VALUES
(10, 'Electrical Engineering'),
(20, 'Computer Science');

-- Insert student records

INSERT INTO students_3nf VALUES
(1, 'Ahmed', 10),
(2, 'John', 20),
(3, 'Mary', 10);

-- Display Third Normal Form results

SELECT
    s.student_id,
    s.student_name,
    d.department_id,
    d.department_name
FROM students_3nf s
JOIN departments_3nf d
    ON s.department_id = d.department_id
ORDER BY s.student_id;


-- ============================================================
-- QUESTION 4: VERIFY DATABASE TABLES
-- ============================================================

-- Verify 1NF

SELECT * FROM students_1nf;
SELECT * FROM student_courses_1nf;

-- Verify 2NF

SELECT * FROM students_2nf;
SELECT * FROM courses_2nf;
SELECT * FROM enrollments_2nf;

-- Verify 3NF

SELECT * FROM students_3nf;
SELECT * FROM departments_3nf;


-- ============================================================
-- QUESTION 5: TEST TABLE RELATIONSHIPS
-- ============================================================

-- Count the number of students

SELECT COUNT(*) AS total_students
FROM students_1nf;

-- Count the number of courses

SELECT COUNT(*) AS total_courses
FROM courses_2nf;

-- Count student enrollments

SELECT COUNT(*) AS total_enrollments
FROM enrollments_2nf;

-- Find students in Electrical Engineering

SELECT
    s.student_name,
    d.department_name
FROM students_3nf s
JOIN departments_3nf d
    ON s.department_id = d.department_id
WHERE d.department_name = 'Electrical Engineering';


-- ============================================================
-- END OF WEEK 7 ASSIGNMENT
-- ============================================================
