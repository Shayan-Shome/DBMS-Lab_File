-- ============================================================
-- DBMS Laboratory File
-- Experiment 05 : Views and Recursive CTE
-- CO3
-- ============================================================
-- Aim: Create SQL views for department salary summary and
--      employee hierarchy. Test updatability of views.
--      Implement a recursive CTE to display reporting chains.
-- ============================================================

USE EmpDeptProj;

-- Cleanup if re-running
DROP VIEW IF EXISTS v_dept_salary_summary;
DROP VIEW IF EXISTS v_emp_hierarchy;

-- ============================================================
-- VIEW 1 : Department salary summary
-- ============================================================
CREATE VIEW v_dept_salary_summary AS
SELECT d.dept_id,
       d.dept_name,
       COUNT(e.emp_id)         AS emp_count,
       SUM(e.salary)           AS total_salary,
       ROUND(AVG(e.salary),2)  AS avg_salary,
       MIN(e.salary)           AS min_salary,
       MAX(e.salary)           AS max_salary
FROM   Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
GROUP  BY d.dept_id, d.dept_name;

-- View output
SELECT * FROM v_dept_salary_summary;

-- ============================================================
-- VIEW 2 : Employee hierarchy (direct manager only)
-- ============================================================
CREATE VIEW v_emp_hierarchy AS
SELECT e.emp_id,
       e.emp_name,
       e.dept_id,
       e.manager_id,
       m.emp_name AS manager_name
FROM   Employee e
LEFT JOIN Employee m ON e.manager_id = m.emp_id;

-- View output (first 10)
SELECT * FROM v_emp_hierarchy LIMIT 10;

-- ============================================================
-- TEST 1 : Update on aggregate view -> NOT updatable
-- Expected: ERROR 1288
-- ============================================================
UPDATE v_dept_salary_summary
SET    total_salary = 1000000
WHERE  dept_id = 1;

-- ============================================================
-- TEST 2 : Insert into join view -> NOT updatable
-- Expected: ERROR 1394 / 1288
-- ============================================================
INSERT INTO v_emp_hierarchy (emp_id, emp_name, dept_id)
VALUES (99, 'Test', 1);

-- ============================================================
-- TEST 3 : Simple single-table view IS updatable
-- ============================================================
CREATE VIEW v_it_employees AS
SELECT emp_id, emp_name, salary, dept_id
FROM   Employee
WHERE  dept_id = 3;

-- Update via simple view (allowed)
UPDATE v_it_employees
SET    salary = salary + 1000
WHERE  emp_id = 13;

-- Confirm the change in the base table
SELECT emp_id, emp_name, salary FROM Employee WHERE emp_id = 13;

-- Roll back to original so other experiments are not affected
UPDATE Employee SET salary = 120000 WHERE emp_id = 13;

-- ============================================================
-- RECURSIVE CTE : reporting chains from every top-level manager
-- ============================================================
WITH RECURSIVE emp_chain AS (

    -- Anchor: employees with no manager (top of hierarchy)
    SELECT emp_id,
           emp_name,
           manager_id,
           1 AS level,
           CAST(emp_name AS CHAR(200)) AS chain
    FROM   Employee
    WHERE  manager_id IS NULL

    UNION ALL

    -- Recursive step: each employee appended to parent's chain
    SELECT e.emp_id,
           e.emp_name,
           e.manager_id,
           ec.level + 1,
           CONCAT(ec.chain, ' -> ', e.emp_name)
    FROM   Employee  e
    JOIN   emp_chain ec ON e.manager_id = ec.emp_id
)
SELECT * FROM emp_chain
ORDER  BY chain;

-- ============================================================
-- BONUS : depth of each employee in the hierarchy
-- ============================================================
WITH RECURSIVE depth_calc AS (
    SELECT emp_id, emp_name, 1 AS depth
    FROM   Employee WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, dc.depth + 1
    FROM   Employee e JOIN depth_calc dc ON e.manager_id = dc.emp_id
)
SELECT depth, COUNT(*) AS emp_count
FROM   depth_calc
GROUP  BY depth
ORDER  BY depth;

-- ============================================================
-- END OF EXPERIMENT 05
-- ============================================================