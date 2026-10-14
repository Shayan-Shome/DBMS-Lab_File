# Experiment 03 — Employee–Department–Project Schema

**Aim:** Create an Employee–Department–Project schema. Insert at least 30 employees across 5 departments and 8 projects. Write SQL queries demonstrating selection, projection, aggregates, GROUP BY, HAVING, CASE expressions, and ORDER BY.

**Course Outcome:** CO2

## Files
| File                | Description                            |
| ------------------- | -------------------------------------- |
| `Experiment-03.sql` | Complete schema, data, and 10+ queries |
| `Experiment-03.pdf` | Lab-file scan                          |

## Schema Overview
- **Department** (dept_id PK) — 5 rows
- **Employee** (emp_id PK, dept_id FK, manager_id self-FK) — 30 rows
- **Project** (proj_id PK, dept_id FK) — 8 rows
- **Works_On** (emp_id + proj_id composite PK) — 32 rows

## Query Groups
| Group | Demonstrates                               |
| ----- | ------------------------------------------ |
| a     | Selection + projection                     |
| b     | DISTINCT projection                        |
| c     | BETWEEN, IN, LIKE                          |
| d     | COUNT, SUM, AVG, MIN, MAX                  |
| e     | GROUP BY with ORDER BY                     |
| f     | HAVING (dept avg, multi-project employees) |
| g     | CASE — salary grade, gender headcount      |
| h     | Multi-key ORDER BY                         |

## Sample Results
- Total employees: 30
- Total salary: ₹18,06,000
- Average salary: ₹60,200
- IT has the highest avg salary (~₹80,166)
- Employees 6 (Farhan) and 18 (Sneha) intentionally unassigned to any project for later LEFT JOIN tests.

## Status
- [x] Schema + data
- [x] All queries tested on MySQL 8
- [x] PDF scanned and placed