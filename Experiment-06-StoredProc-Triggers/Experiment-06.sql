-- ============================================================
-- DBMS Laboratory File
-- Experiment 06 : Stored Procedure and Triggers
-- CO3
-- ============================================================
-- Aim: Create a stored procedure transfer_employee(emp_id,
--      new_dept_id) with validation and error handling.
--      Implement triggers for salary validation and audit
--      logging. Test edge cases.
-- ============================================================
-- Requires: MySQL 8.0 / MariaDB 10.5+ (DELIMITER, SIGNAL)
-- Run Experiment 03 first to create EmpDeptProj schema.
-- ============================================================

USE EmpDeptProj;

-- Cleanup if re-running
DROP TRIGGER IF EXISTS trg_salary_validate;
DROP TRIGGER IF EXISTS trg_emp_audit_update;
DROP PROCEDURE IF EXISTS transfer_employee;
DROP TABLE IF EXISTS Emp_Audit;

-- ============================================================
-- AUDIT TABLE
-- ============================================================
CREATE TABLE Emp_Audit (
    audit_id     INT AUTO_INCREMENT PRIMARY KEY,
    emp_id       INT,
    action       VARCHAR(10),
    old_salary   DECIMAL(10,2),
    new_salary   DECIMAL(10,2),
    old_dept     INT,
    new_dept     INT,
    action_time  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(80)
);

-- ============================================================
-- TRIGGER 1 : Salary validation on INSERT
-- Rejects zero or negative salaries.
-- ============================================================
DELIMITER $$

CREATE TRIGGER trg_salary_validate
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than zero.';
    END IF;
END$$

-- ============================================================
-- TRIGGER 2 : Audit logging on UPDATE
-- Logs any change to salary or dept_id.
-- ============================================================
CREATE TRIGGER trg_emp_audit_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary
       OR OLD.dept_id <> NEW.dept_id
       OR (OLD.dept_id IS NULL) <> (NEW.dept_id IS NULL) THEN
        INSERT INTO Emp_Audit
            (emp_id, action, old_salary, new_salary,
             old_dept, new_dept, performed_by)
        VALUES
            (OLD.emp_id, 'UPDATE', OLD.salary, NEW.salary,
             OLD.dept_id, NEW.dept_id, USER());
    END IF;
END$$

-- ============================================================
-- STORED PROCEDURE : transfer_employee
-- Validates employee, department, and no-op transfer.
-- Rolls back on any exception.
-- ============================================================
CREATE PROCEDURE transfer_employee(
    IN p_emp_id      INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_old_dept    INT;
    DECLARE v_emp_exists  INT DEFAULT 0;
    DECLARE v_dept_exists INT DEFAULT 0;

    -- Global error handler : rollback and report
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Transaction rolled back due to an exception.'
               AS message;
    END;

    START TRANSACTION;

    -- Validate employee
    SELECT COUNT(*) INTO v_emp_exists
    FROM   Employee WHERE emp_id = p_emp_id;

    IF v_emp_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee does not exist.';
    END IF;

    -- Validate department
    SELECT COUNT(*) INTO v_dept_exists
    FROM   Department WHERE dept_id = p_new_dept_id;

    IF v_dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist.';
    END IF;

    -- Fetch current department
    SELECT dept_id INTO v_old_dept
    FROM   Employee WHERE emp_id = p_emp_id;

    -- Validate no-op transfer
    IF v_old_dept = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee is already in the specified department.';
    END IF;

    -- Perform transfer
    UPDATE Employee
    SET    dept_id = p_new_dept_id
    WHERE  emp_id  = p_emp_id;

    COMMIT;

    SELECT CONCAT('Employee ', p_emp_id,
                  ' transferred from dept ', v_old_dept,
                  ' to ', p_new_dept_id) AS message;
END$$

DELIMITER ;

-- ============================================================
-- TESTS
-- ============================================================
-- Test 1 : Valid transfer
CALL transfer_employee(1, 3);

-- Test 2 : Non-existent employee -> error 1644
CALL transfer_employee(999, 2);

-- Test 3 : Non-existent department -> error 1644
CALL transfer_employee(2, 99);

-- Test 4 : Same department (no-op) -> error 1644
CALL transfer_employee(3, 1);

-- Test 5 : Trigger blocks negative salary -> error 1644
INSERT INTO Employee (emp_id, emp_name, salary, dept_id)
VALUES (99, 'Test', -5000, 1);

-- Test 6 : Audit log check
SELECT * FROM Emp_Audit;

-- ============================================================
-- BONUS : Clean-up so experiments 07-10 start fresh
-- ============================================================
-- UPDATE Employee SET dept_id = 1 WHERE emp_id = 1;
-- TRUNCATE TABLE Emp_Audit;

-- ============================================================
-- END OF EXPERIMENT 06
-- ============================================================