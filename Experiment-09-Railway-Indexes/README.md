# Experiment 09 — Railway Booking Index Benchmarking

**Aim:** Create a Railway Booking table with at least 5,000 records. Benchmark query performance before and after creating single and composite indexes. Use EXPLAIN to compare execution plans.

**Course Outcome:** CO5

## Files
| File                | Description                                                 |
| ------------------- | ----------------------------------------------------------- |
| `Experiment-09.sql` | 5000-row generator + 4 benchmarks with EXPLAIN before/after |
| `Experiment-09.pdf` | Lab-file scan with EXPLAIN screenshots                      |

## Data Generation
Cross-join of 4 `digits` tables (10^4 = 10,000) → `LIMIT 5000` gives exactly 5000 unique rows. No `cte_max_recursion_depth` issues.

## Benchmarks
| #   | Query                                 | Optimisation                          |
| --- | ------------------------------------- | ------------------------------------- |
| 1   | `train_no + source_station`           | single idx → composite idx (covering) |
| 2   | `travel_date + seat_class`            | composite `(travel_date, seat_class)` |
| 3   | `passenger_name LIKE 'prefix%'`       | single idx `(passenger_name)`         |
| 4   | `ORDER BY travel_date DESC LIMIT 100` | single idx removes filesort           |

## Key Observations
- `type` in EXPLAIN changes **`ALL` → `ref`/`range`** after indexing → full scan eliminated.
- `rows` estimate drops from **~5000 → ~25** on `train_no` filter.
- `Extra` column changes: `Using filesort` → `NULL` (or `Using index`) after `ORDER BY` index.
- Composite `(train_no, source_station)` lets the query use a **covering index** → no table lookup.

## When NOT to Index
Indexes slow down INSERT/UPDATE/DELETE and use disk. Only add them on columns frequently used in `WHERE`, `JOIN`, `ORDER BY`.

## Status
- [x] 5000 rows generated
- [x] 4 benchmarks with EXPLAIN
- [x] PDF scanned