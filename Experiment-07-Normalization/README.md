# Experiment 07 — Normalization UNF → 3NF → BCNF

**Aim:** Given a denormalized Sales table, identify functional dependencies and normalize step-by-step from UNF to 3NF and BCNF. Verify lossless join and dependency preservation using SQL queries.

**Course Outcome:** CO4

## Files
| File                | Description                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| `Experiment-07.sql` | UNF → 1NF → 2NF → 3NF → BCNF with lossless-join and FD-preservation checks |
| `Experiment-07.pdf` | Lab-file scan                                                              |

## Functional Dependencies
| #   | FD                                              |
| --- | ----------------------------------------------- |
| FD1 | `order_id → order_date, customer_id`            |
| FD2 | `customer_id → customer_name, customer_city`    |
| FD3 | `product_id → product_name, seller_id`          |
| FD4 | `seller_id → seller_name, seller_city`          |
| FD5 | `(order_id, product_id) → quantity, unit_price` |

## Normalization Steps
1. **UNF** — products packed as comma-separated values (repeating groups).
2. **1NF** — split into one row per product; cell values atomic.
3. **2NF** — remove partial deps via three tables: `Orders`, `Products`, `OrderLine`.
4. **3NF** — remove transitive deps via `Customers`, `Sellers`.
5. **BCNF** — every determinant in the 5-table schema is a candidate key → already in BCNF.

## Verification
- **Lossless join:** `joined_rows = 6` matches `OrderLine` row count → no rows lost.
- **Dependency preservation:** each FD check query returns **0 rows** → all FDs enforceable within a single table.

## Status
- [x] All 5 normalization stages coded
- [x] Lossless join verified
- [x] Dependency preservation verified
- [x] PDF scanned