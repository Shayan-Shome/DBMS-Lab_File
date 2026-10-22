# Experiment 10 — Query Optimization on 10,000 rows

**Aim:** Generate a dataset with at least 10,000 rows. Write five slow queries, analyze using EXPLAIN, optimize using indexing and query rewriting, and compare execution time before and after optimization.

**Course Outcome:** CO5

## Files
| File                | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| `Experiment-10.sql` | 10,000-row generator + 5 queries with before/after EXPLAIN and timing |
| `Experiment-10.pdf` | Lab-file scan with EXPLAIN screenshots                                |

## Optimisation Patterns Demonstrated
| Query | Anti-pattern                             | Fix                                                                                         |
| ----- | ---------------------------------------- | ------------------------------------------------------------------------------------------- |
| Q1    | `YEAR(date) = 2024` (function on column) | Range predicate `date >= '2024-01-01' AND < '2025-01-01'` + composite `(region, sale_date)` |
| Q2    | Full scan on `status + amount`           | Composite index `(status, amount)`                                                          |
| Q3    | `IN (SELECT …)` correlation              | Rewrite as `JOIN (SELECT DISTINCT …)`                                                       |
| Q4    | `ORDER BY` un-indexed column             | Index on `sale_date` — filesort removed                                                     |
| Q5    | `LIKE '%CARD%'` (leading wildcard)       | Normalise data → `=` predicate + covering index `(payment_method, customer_id)`             |

## Key EXPLAIN Signals
- `type` changes: **`ALL` → `ref`/`range`/`index`**
- `rows`: drops from **~10000** to **~100s**
- `Extra`: removes **`Using filesort`** and **`Using temporary`**
- `key`: shows the exact index chosen

## Rules of Thumb
1. Never wrap indexed columns in a function in WHERE.
2. Use composite indexes with **equality column first, range column second**.
3. Rewrite `IN (subquery)` as `JOIN (subquery)` when the outer set is large.
4. Add an index on the `ORDER BY` column when combined with `LIMIT`.
5. Leading wildcards (`LIKE '%x%'`) can never use a B-tree index — restructure the data.

## Status
- [x] 10,000 rows generated
- [x] 5 slow queries with EXPLAIN before/after
- [x] Timings captured
- [x] PDF scanned