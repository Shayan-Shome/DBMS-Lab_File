# Experiment 04 — Joins, Subqueries and EXPLAIN

**Aim:** Using the Employee schema, write queries with INNER JOIN, LEFT JOIN, self-join, 3-way join, correlated subqueries, EXISTS, and simulated INTERSECT and EXCEPT. Compare execution plans using EXPLAIN.

**Course Outcome:** CO2

## Files
| File                | Description                         |
| ------------------- | ----------------------------------- |
| `Experiment-04.sql` | All 9 query groups + EXPLAIN blocks |
| `Experiment-04.pdf` | Lab-file scan                       |

## Query Coverage
| #   | Query type          | Purpose                                    |
| --- | ------------------- | ------------------------------------------ |
| 1   | INNER JOIN          | Employee ↔ Department                      |
| 2   | LEFT JOIN           | Include employees without projects         |
| 3   | SELF-JOIN           | Employee ↔ Manager                         |
| 4   | 3-way join          | Employee + Works_On + Project + Department |
| 5   | Correlated subquery | Above department-average earners           |
| 6   | EXISTS / NOT EXISTS | Employees on projects / empty departments  |
| 7   | Simulated INTERSECT | Managers who also work on projects         |
| 8   | Simulated EXCEPT    | Employees with no project                  |
| 9   | EXPLAIN             | Plan comparison before/after indexing      |

## EXPLAIN Observations
- 3-way join → nested-loop with `eq_ref` lookup on `Project` (PK).
- EXISTS version → `DEPENDENT SUBQUERY`; fast for small outer results.
- INNER vs LEFT → same access path when every FK is populated.
- After creating indexes, `type` changes from `ALL` → `ref` and `rows` drops.

## Status
- [x] All queries tested on MySQL 8
- [x] EXPLAIN output captured
- [x] PDF scanned and placed