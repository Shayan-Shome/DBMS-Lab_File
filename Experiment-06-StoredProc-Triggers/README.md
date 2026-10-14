# Experiment 06 — Stored Procedure and Triggers

**Aim:** Create a stored procedure `transfer_employee(emp_id, new_dept_id)` with validation and error handling. Implement triggers for salary validation and audit logging. Test edge cases.

**Course Outcome:** CO3

## Files
| File                | Description                    |
| ------------------- | ------------------------------ |
| `Experiment-06.sql` | Procedure + 2 triggers + tests |
| `Experiment-06.pdf` | Lab-file scan                  |

## Components

### Stored Procedure — `transfer_employee(emp_id, new_dept_id)`
- Validates employee exists.
- Validates new department exists.
- Rejects no-op transfers (same department).
- Uses `START TRANSACTION` + `COMMIT`.
- Global `EXIT HANDLER FOR SQLEXCEPTION` rolls back on any error.

### Trigger 1 — `trg_salary_validate`
Fires **BEFORE INSERT** on Employee. Raises `SQLSTATE 45000` if `salary <= 0`.

### Trigger 2 — `trg_emp_audit_update`
Fires **AFTER UPDATE** on Employee. Inserts into `Emp_Audit` when salary or dept_id changes.

## Edge Cases Tested

| Test | Input                       | Expected Output                             |
| ---- | --------------------------- | ------------------------------------------- |
| 1    | `transfer_employee(1, 3)`   | Success — Employee transferred              |
| 2    | `transfer_employee(999, 2)` | **ERROR 1644** — Employee does not exist    |
| 3    | `transfer_employee(2, 99)`  | **ERROR 1644** — Department does not exist  |
| 4    | `transfer_employee(3, 1)`   | **ERROR 1644** — Already in that department |
| 5    | INSERT with salary = -5000  | **ERROR 1644** — Salary must be > 0         |
| 6    | `SELECT * FROM Emp_Audit`   | 1 row logged for test 1                     |

**Important:** Because tests 2–5 intentionally raise errors, run **each CALL / INSERT in a separate query box**. If you run the whole script end-to-end, the compiler stops at the first expected error.

## Requirements
- MySQL 8.0+ (needs `DELIMITER`, `SIGNAL SQLSTATE`)
- dbfiddle.uk → select **MySQL 8.0** engine (not SQLite)

## Status
- [x] Procedure + triggers created
- [x] All 6 edge cases tested
- [x] Audit row verified
- [x] PDF scanned and placed