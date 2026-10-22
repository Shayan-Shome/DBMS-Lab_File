# Experiment 08 — Transactions & Isolation Levels

**Aim:** Implement banking-style transactions using BEGIN, COMMIT, ROLLBACK, and SAVEPOINT. Simulate partial failures. Demonstrate isolation levels and concurrency anomalies using two sessions.

**Course Outcome:** CO4

## Files
| File                | Description                                                    |
| ------------------- | -------------------------------------------------------------- |
| `Experiment-08.sql` | SAVEPOINT/ROLLBACK/COMMIT demos + isolation-level instructions |
| `Experiment-08.pdf` | Lab-file scan (incl. screenshots of two-session demo)          |

## Parts
| Part | Demonstrates                                            |
| ---- | ------------------------------------------------------- |
| A    | `SAVEPOINT` + `ROLLBACK TO SAVEPOINT` (partial undo)    |
| B    | `ROLLBACK` (full undo)                                  |
| C    | `COMMIT` (persist)                                      |
| D    | Partial failure simulation                              |
| E    | Isolation levels + concurrency anomalies (two sessions) |

## Anomalies Demonstrated
| Anomaly             | Isolation that shows it | Isolation that prevents it |
| ------------------- | ----------------------- | -------------------------- |
| Dirty read          | READ UNCOMMITTED        | READ COMMITTED+            |
| Non-repeatable read | READ COMMITTED          | REPEATABLE READ+           |
| Phantom read        | REPEATABLE READ         | SERIALIZABLE               |

MySQL 8 default isolation = **REPEATABLE READ**.

## Note on Two-Session Demos
Parts A–D run in a single session (dbfiddle / onecompiler).
Part E requires **two query tabs** (dbfiddle "Add query tab" or two MySQL clients). Screenshots of each tab go in the PDF.

## Status
- [x] Single-session demos (A–D) verified
- [x] Two-session isolation demos captured (E)
- [x] PDF scanned