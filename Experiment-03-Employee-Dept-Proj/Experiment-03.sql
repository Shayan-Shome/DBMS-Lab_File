-- ============================================================
-- DBMS Laboratory File
-- Experiment 03 : Employee–Department–Project schema
-- CO2
-- ============================================================
-- Aim: Create an Employee–Department–Project schema. Insert at
--      least 30 employees across 5 departments and 8 projects.
--      Demonstrate selection, projection, aggregates, GROUP BY,
--      HAVING, CASE expressions, ORDER BY.
-- ============================================================

DROP DATABASE IF EXISTS EmpDeptProj;
CREATE DATABASE EmpDeptProj;
USE EmpDeptProj;

-- ------------------------------------------------------------
-- SCHEMA
-- ------------------------------------------------------------
CREATE TABLE Department (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(30) NOT NULL UNIQUE,
    location  VARCHAR(30)
);

CREATE TABLE Employee (
    emp_id     INT PRIMARY KEY,
    emp_name   VARCHAR(30) NOT NULL,
    gender     CHAR(1) CHECK (gender IN ('M','F')),
    salary     DECIMAL(10,2) NOT NULL,
    hire_date  DATE,
    dept_id    INT,
    manager_id INT,
    FOREIGN KEY (dept_id)    REFERENCES Department(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id)
);

CREATE TABLE Project (
    proj_id   INT PRIMARY KEY,
    proj_name VARCHAR(30) NOT NULL,
    budget    DECIMAL(12,2),
    dept_id   INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Works_On (
    emp_id  INT,
    proj_id INT,
    hours   INT NOT NULL,
    PRIMARY KEY (emp_id, proj_id),
    FOREIGN KEY (emp_id)  REFERENCES Employee(emp_id),
    FOREIGN KEY (proj_id) REFERENCES Project(proj_id)
);

-- ------------------------------------------------------------
-- DATA : 5 departments
-- ------------------------------------------------------------
INSERT INTO Department VALUES
(1,'HR','Delhi'),
(2,'Finance','Mumbai'),
(3,'IT','Bengaluru'),
(4,'Sales','Pune'),
(5,'Operations','Chennai');

-- ------------------------------------------------------------
-- DATA : 8 projects
-- ------------------------------------------------------------
INSERT INTO Project VALUES
(101,'Payroll System',    500000,1),
(102,'Audit Tool',        750000,2),
(103,'Website Revamp',   1200000,3),
(104,'Mobile App',       1500000,3),
(105,'CRM Upgrade',       900000,4),
(106,'Logistics Tracker', 600000,5),
(107,'Data Warehouse',   2000000,3),
(108,'Marketing Portal',  400000,4);

-- ------------------------------------------------------------
-- DATA : 30 employees  (6 per department)
-- ------------------------------------------------------------
INSERT INTO Employee VALUES
-- HR
(1 ,'Aarav' ,'M', 90000,'2015-01-10',1,NULL),
(2 ,'Bhavna','F', 55000,'2017-03-12',1,1),
(3 ,'Chirag','M', 48000,'2018-07-01',1,1),
(4 ,'Divya' ,'F', 52000,'2019-02-20',1,1),
(5 ,'Esha'  ,'F', 45000,'2020-11-05',1,1),
(6 ,'Farhan','M', 41000,'2021-06-15',1,1),
-- Finance
(7 ,'Gaurav','M', 95000,'2014-05-01',2,NULL),
(8 ,'Hina'  ,'F', 62000,'2016-08-19',2,7),
(9 ,'Irfan' ,'M', 58000,'2018-01-25',2,7),
(10,'Jaya'  ,'F', 53000,'2019-09-30',2,7),
(11,'Karan' ,'M', 49000,'2020-04-11',2,7),
(12,'Leela' ,'F', 44000,'2022-02-14',2,7),
-- IT
(13,'Manish','M',120000,'2013-03-03',3,NULL),
(14,'Nisha' ,'F', 88000,'2015-10-10',3,13),
(15,'Om'    ,'M', 76000,'2017-12-01',3,13),
(16,'Priya' ,'F', 72000,'2018-06-06',3,13),
(17,'Rahul' ,'M', 65000,'2020-08-08',3,13),
(18,'Sneha' ,'F', 60000,'2021-09-09',3,13),
-- Sales
(19,'Tarun' ,'M', 85000,'2014-11-11',4,NULL),
(20,'Uma'   ,'F', 59000,'2017-01-17',4,19),
(21,'Varun' ,'M', 56000,'2018-03-21',4,19),
(22,'Waseem','M', 51000,'2019-07-07',4,19),
(23,'Xena'  ,'F', 47000,'2021-05-05',4,19),
(24,'Yogesh','M', 43000,'2022-10-10',4,19),
-- Operations
(25,'Zara'  ,'F', 78000,'2016-02-02',5,NULL),
(26,'Anil'  ,'M', 54000,'2017-06-16',5,25),
(27,'Bindu' ,'F', 50000,'2019-04-04',5,25),
(28,'Chetan','M', 46000,'2020-12-12',5,25),
(29,'Deepa' ,'F', 42000,'2021-11-11',5,25),
(30,'Ejaz'  ,'M', 38000,'2023-01-20',5,25);

-- ------------------------------------------------------------
-- Works_On : most employees on 1 project, some on 2
-- (Employees 6 and 18 are intentionally left out for later LEFT JOIN tests)
-- ------------------------------------------------------------
INSERT INTO Works_On VALUES
(1,101,20),(2,101,35),(3,101,15),(4,101,25),(5,101,10),
(7,102,40),(8,102,25),(9,102,30),(10,102,20),(11,102,15),(12,102,35),
(13,103,50),(13,107,30),
(14,103,40),(14,104,20),
(15,103,35),(15,107,25),
(16,104,45),(17,104,30),
(19,105,25),(20,105,30),
(21,108,20),(22,108,35),
(23,105,15),(24,108,10),
(25,106,40),(26,106,30),(27,106,25),(28,106,20),(29,106,15),(30,106,10);

-- ============================================================
-- QUERIES
-- ============================================================

-- (a) Selection + Projection
-- Employees in IT earning above 60k
SELECT emp_name, salary
FROM   Employee
WHERE  salary > 60000
  AND  dept_id = 3;

-- (b) Projection with DISTINCT
SELECT DISTINCT dept_id FROM Employee;

-- (c) Selection with BETWEEN / IN / LIKE
SELECT emp_name, hire_date
FROM   Employee
WHERE  hire_date BETWEEN '2017-01-01' AND '2019-12-31';

SELECT emp_name, dept_id
FROM   Employee
WHERE  dept_id IN (1,3,5);

SELECT emp_name
FROM   Employee
WHERE  emp_name LIKE 'A%';

-- (d) Aggregate Functions
SELECT COUNT(*)              AS total_emp,
       SUM(salary)           AS total_salary,
       ROUND(AVG(salary),2)  AS avg_salary,
       MIN(salary)           AS min_salary,
       MAX(salary)           AS max_salary
FROM   Employee;

-- (e) GROUP BY : department-wise summary
SELECT d.dept_name,
       COUNT(e.emp_id)         AS emp_count,
       ROUND(AVG(e.salary),2)  AS avg_salary,
       SUM(e.salary)           AS total_salary
FROM   Department d
JOIN   Employee   e ON d.dept_id = e.dept_id
GROUP  BY d.dept_id, d.dept_name
ORDER  BY avg_salary DESC;

-- (f) HAVING
SELECT d.dept_name,
       ROUND(AVG(e.salary),2) AS avg_salary
FROM   Department d
JOIN   Employee   e ON d.dept_id = e.dept_id
GROUP  BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 55000;

-- Employees working on more than one project
SELECT e.emp_name, COUNT(*) AS proj_count
FROM   Employee e
JOIN   Works_On w ON e.emp_id = w.emp_id
GROUP  BY e.emp_id, e.emp_name
HAVING COUNT(*) > 1;

-- (g) CASE expressions
SELECT emp_name, salary,
       CASE
           WHEN salary >= 80000 THEN 'High'
           WHEN salary >= 55000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_grade
FROM   Employee
ORDER  BY salary DESC;

-- Gender-wise headcount per department
SELECT d.dept_name,
       SUM(CASE WHEN e.gender = 'M' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN e.gender = 'F' THEN 1 ELSE 0 END) AS female_count
FROM   Department d
JOIN   Employee   e ON d.dept_id = e.dept_id
GROUP  BY d.dept_id, d.dept_name;

-- (h) ORDER BY : two keys
SELECT emp_name, dept_id, salary
FROM   Employee
ORDER  BY dept_id ASC, salary DESC;

-- ============================================================
-- END OF EXPERIMENT 03
-- ============================================================