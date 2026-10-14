# Experiment 05 — Views and Recursive CTE

**Aim:** Create SQL views for department salary summary and employee hierarchy. Test updatability of views. Implement a recursive CTE to display reporting chains.

**Course Outcome:** CO3

## Files
| File                | Description                              |
| ------------------- | ---------------------------------------- |
| `Experiment-05.sql` | Views, updatability tests, recursive CTE |
| `Experiment-05.pdf` | Lab-file scan                            |

## Views Created
1. **`v_dept_salary_summary`** — aggregate view (GROUP BY). **Not updatable.**
2. **`v_emp_hierarchy`** — join view (self-join). **Not updatable.**
3. **`v_it_employees`** — simple single-table view. **Updatable.**

## Updatability Test Results
| Test                              | Result                                    |
| --------------------------------- | ----------------------------------------- |
| UPDATE on `v_dept_salary_summary` | **ERROR 1288** — view contains aggregates |
| INSERT into `v_emp_hierarchy`     | **ERROR 1394** — view contains join       |
| UPDATE on `v_it_employees`        | **Success** — propagated to base table    |

A view is updatable **only if** it is derived from a single base table with no GROUP BY, no aggregates, no DISTINCT, no UNION — and every NOT NULL column of the base table is included.

## Recursive CTE
Uses MySQL 8's `WITH RECURSIVE` to walk the manager hierarchy. Output shows chains like:
Manish -> Nisha
Manish -> Om
Manish -> Priya
Gaurav -> Hina
Aarav -> Bhavna
...

text

Depth-counting CTE shows how many employees sit at each level.

## Requirements
- MySQL **8.0+** (recursive CTE, window functions).
- Run Experiment 03 first, or create the schema manually.

## Status
- [x] Views created and tested
- [x] Updatability rules verified
- [x] Recursive CTE working
- [x] PDF scanned and placed