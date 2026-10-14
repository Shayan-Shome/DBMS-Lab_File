-- ============================================================
-- DBMS Laboratory File
-- Experiment 04 : Joins, Subqueries and EXPLAIN
-- CO2
-- ============================================================
-- Aim: Using the Employee schema from Experiment 03, write
--      queries with INNER JOIN, LEFT JOIN, self-join, 3-way
--      join, correlated subqueries, EXISTS, and simulated
--      INTERSECT and EXCEPT. Compare execution plans using
--      EXPLAIN.
-- ============================================================
-- NOTE: This experiment assumes Experiment 03 schema + data
--       already exists (database EmpDeptProj). If not, run
--       Experiment-03.sql first, or run the mini setup below.
-- ============================================================

USE EmpDeptProj;

-- ============================================================
-- 1. INNER JOIN : employees with their department
-- ============================================================
SELECT e.emp_name,
       d.dept_name,
       d.location
FROM   Employee   e
INNER JOIN Department d ON e.dept_id = d.dept_id
ORDER  BY d.dept_name, e.emp_name;

-- ============================================================
-- 2. LEFT JOIN : all employees, even those without a project
-- ============================================================
SELECT e.emp_name,
       w.proj_id,
       w.hours
FROM   Employee e
LEFT JOIN Works_On w ON e.emp_id = w.emp_id
ORDER  BY e.emp_id;

-- LEFT JOIN at department level (count even if none)
SELECT d.dept_name,
       COUNT(e.emp_id) AS emp_count
FROM   Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
GROUP  BY d.dept_id, d.dept_name;

-- ============================================================
-- 3. SELF-JOIN : employee ↔ manager
-- ============================================================
SELECT e.emp_name AS employee,
       m.emp_name AS manager
FROM   Employee e
LEFT JOIN Employee m ON e.manager_id = m.emp_id
ORDER  BY e.emp_id;

-- ============================================================
-- 4. THREE-WAY JOIN : Employee + Works_On + Project + Department
-- ============================================================
SELECT e.emp_name,
       d.dept_name,
       p.proj_name,
       w.hours
FROM   Employee   e
JOIN   Works_On   w ON e.emp_id  = w.emp_id
JOIN   Project    p ON w.proj_id = p.proj_id
JOIN   Department d ON e.dept_id = d.dept_id
WHERE  d.dept_name = 'IT'
ORDER  BY e.emp_name;

-- ============================================================
-- 5. CORRELATED SUBQUERY : employees earning above their own dept average
-- ============================================================
SELECT e.emp_name,
       e.salary,
       e.dept_id
FROM   Employee e
WHERE  e.salary > (SELECT AVG(salary)
                   FROM   Employee x
                   WHERE  x.dept_id = e.dept_id)
ORDER  BY e.dept_id, e.salary DESC;

-- ============================================================
-- 6. EXISTS : employees who are on at least one project
-- ============================================================
SELECT e.emp_id, e.emp_name
FROM   Employee e
WHERE  EXISTS (SELECT 1
               FROM   Works_On w
               WHERE  w.emp_id = e.emp_id);

-- NOT EXISTS : departments with no employees
SELECT d.dept_name
FROM   Department d
WHERE  NOT EXISTS (SELECT 1
                   FROM   Employee e
                   WHERE  e.dept_id = d.dept_id);

-- ============================================================
-- 7. SIMULATED INTERSECT
-- MySQL has no INTERSECT prior to 8.0.31. Use IN/IN or EXISTS.
-- Example: managers who are also on at least one project.
-- ============================================================
SELECT e.emp_id, e.emp_name
FROM   Employee e
WHERE  e.emp_id IN (SELECT manager_id FROM Employee
                    WHERE  manager_id IS NOT NULL)
  AND  e.emp_id IN (SELECT emp_id FROM Works_On);

-- IT employees who worked on the 'Website Revamp' project
SELECT e.emp_id, e.emp_name
FROM   Employee e
WHERE  e.dept_id = 3
  AND  e.emp_id IN (SELECT emp_id FROM Works_On WHERE proj_id = 103);

-- ============================================================
-- 8. SIMULATED EXCEPT
-- MySQL < 8.0.31 has no EXCEPT. Use NOT IN or NOT EXISTS.
-- ============================================================
-- Employees not assigned to any project
SELECT e.emp_id, e.emp_name
FROM   Employee e
WHERE  e.emp_id NOT IN (SELECT w.emp_id FROM Works_On w);

-- Same via NOT EXISTS (safer with NULLs)
SELECT e.emp_id, e.emp_name
FROM   Employee e
WHERE  NOT EXISTS (SELECT 1 FROM Works_On w WHERE w.emp_id = e.emp_id);

-- IT employees who are NOT on project 107
SELECT e.emp_id, e.emp_name
FROM   Employee e
WHERE  e.dept_id = 3
  AND  e.emp_id NOT IN (SELECT w.emp_id FROM Works_On w WHERE w.proj_id = 107);

-- ============================================================
-- 9. EXPLAIN : execution-plan comparison
-- ============================================================

-- Plan A : 3-way join
EXPLAIN
SELECT e.emp_name, p.proj_name
FROM   Employee e
JOIN   Works_On w ON e.emp_id  = w.emp_id
JOIN   Project  p ON w.proj_id = p.proj_id
WHERE  p.proj_name = 'Website Revamp';

-- Plan B : equivalent EXISTS / correlated subquery
EXPLAIN
SELECT e.emp_name
FROM   Employee e
WHERE  EXISTS (SELECT 1
               FROM   Works_On w
               JOIN   Project  p ON w.proj_id = p.proj_id
               WHERE  w.emp_id = e.emp_id
                 AND  p.proj_name = 'Website Revamp');

-- Plan C : INNER JOIN vs LEFT JOIN
EXPLAIN
SELECT e.emp_name, d.dept_name
FROM   Employee e INNER JOIN Department d ON e.dept_id = d.dept_id;

EXPLAIN
SELECT e.emp_name, d.dept_name
FROM   Employee e LEFT  JOIN Department d ON e.dept_id = d.dept_id;

-- ------------------------------------------------------------
-- Add indexes and re-check plans
-- ------------------------------------------------------------
CREATE INDEX idx_emp_dept  ON Employee(dept_id);
CREATE INDEX idx_wo_proj   ON Works_On(proj_id);
CREATE INDEX idx_proj_name ON Project(proj_name);

-- Re-run Plan A and Plan C after indexing — type should change
-- from ALL to ref / index and rows estimate should drop.
EXPLAIN
SELECT e.emp_name, p.proj_name
FROM   Employee e
JOIN   Works_On w ON e.emp_id  = w.emp_id
JOIN   Project  p ON w.proj_id = p.proj_id
WHERE  p.proj_name = 'Website Revamp';

-- ============================================================
-- END OF EXPERIMENT 04
-- ============================================================