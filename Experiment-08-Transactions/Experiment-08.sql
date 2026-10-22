-- ============================================================
-- DBMS Laboratory File
-- Experiment 08 : Transactions, SAVEPOINT, Isolation Levels
-- CO4
-- ============================================================
-- Aim: Implement banking-style transactions using BEGIN,
--      COMMIT, ROLLBACK, SAVEPOINT. Simulate partial failures.
--      Demonstrate isolation levels and concurrency anomalies
--      using two sessions.
-- ============================================================

DROP DATABASE IF EXISTS BankingDB;
CREATE DATABASE BankingDB;
USE BankingDB;

CREATE TABLE Accounts (
    account_id  INT PRIMARY KEY,
    holder_name VARCHAR(50),
    balance     DECIMAL(12,2) NOT NULL DEFAULT 0
);

INSERT INTO Accounts VALUES
(1, 'Ravi',  10000.00),
(2, 'Priya',  5000.00);

SELECT * FROM Accounts;   -- initial: 10000, 5000

-- ============================================================
-- PART A — SAVEPOINT with partial rollback
-- ============================================================
START TRANSACTION;

UPDATE Accounts SET balance = balance - 2000 WHERE account_id = 1;
SAVEPOINT after_debit;

UPDATE Accounts SET balance = balance + 2000 WHERE account_id = 2;
SAVEPOINT after_credit;

-- Suppose the next statement was a mistake
UPDATE Accounts SET balance = balance - 500 WHERE account_id = 1;

-- Undo only the last statement
ROLLBACK TO SAVEPOINT after_credit;

-- Expected: account 1 = 8000, account 2 = 7000
SELECT * FROM Accounts;

COMMIT;

-- Final state
SELECT * FROM Accounts;

-- ============================================================
-- PART B — ROLLBACK (full transaction undo)
-- ============================================================
START TRANSACTION;

UPDATE Accounts SET balance = balance - 1000 WHERE account_id = 1;
UPDATE Accounts SET balance = balance + 1000 WHERE account_id = 2;

-- Change of plan — undo everything in this transaction
ROLLBACK;

-- Expected: state unchanged (1 = 8000, 2 = 7000)
SELECT * FROM Accounts;

-- ============================================================
-- PART C — COMMIT (persist the transaction)
-- ============================================================
START TRANSACTION;

UPDATE Accounts SET balance = balance - 1000 WHERE account_id = 1;
UPDATE Accounts SET balance = balance + 1000 WHERE account_id = 2;

COMMIT;

-- Expected: 1 = 7000, 2 = 8000
SELECT * FROM Accounts;

-- ============================================================
-- PART D — Simulated partial failure
-- ============================================================
START TRANSACTION;

UPDATE Accounts SET balance = balance - 3000 WHERE account_id = 1;

-- Simulate failure: CHECK will reject a negative balance
UPDATE Accounts SET balance = -9999 WHERE account_id = 2;

-- Because balance becomes negative, ROLLBACK immediately
ROLLBACK;

SELECT * FROM Accounts;   -- state unchanged

-- ============================================================
-- PART E — ISOLATION LEVELS (two sessions)
-- ============================================================
-- Run the following blocks in TWO SEPARATE query tabs.
-- dbfiddle : use "Add query tab" for a second session
-- MySQL CLI: open two clients
-- Session A = writer, Session B = reader.

-- ---------------- DIRTY READ (READ UNCOMMITTED) ----------------
-- SESSION A
--   SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--   START TRANSACTION;
--   UPDATE Accounts SET balance = 99999 WHERE account_id = 1;
--   -- do NOT commit
--
-- SESSION B
--   SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--   START TRANSACTION;
--   SELECT * FROM Accounts WHERE account_id = 1;
--   -- expected: 99999  (DIRTY READ — uncommitted data visible)
--
-- SESSION A
--   ROLLBACK;
--
-- SESSION B
--   SELECT * FROM Accounts WHERE account_id = 1;
--   -- expected: original value again (dirty read disappears)
--   COMMIT;

-- ---------------- NON-REPEATABLE READ ----------------
-- SESSION B (with READ COMMITTED, same row can change mid-txn)
--   SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
--   START TRANSACTION;
--   SELECT balance FROM Accounts WHERE account_id = 1;   -- e.g. 7000
--
-- SESSION A
--   UPDATE Accounts SET balance = 500 WHERE account_id = 1;
--   COMMIT;
--
-- SESSION B
--   SELECT balance FROM Accounts WHERE account_id = 1;   -- 500 (changed!)
--   COMMIT;
--
-- With REPEATABLE READ, the second SELECT in SESSION B still sees 7000.

-- ---------------- PHANTOM READ ----------------
-- SESSION B (REPEATABLE READ — phantoms still possible in some engines)
--   SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
--   START TRANSACTION;
--   SELECT COUNT(*) FROM Accounts WHERE balance > 1000;
--
-- SESSION A
--   INSERT INTO Accounts VALUES (3, 'Amit', 5000);
--   COMMIT;
--
-- SESSION B
--   SELECT COUNT(*) FROM Accounts WHERE balance > 1000;   -- count increases
--
-- With SERIALIZABLE, SESSION B would either block or be aborted.

-- ---------------- SERIALIZABLE ----------------
-- SESSION A
--   SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--   START TRANSACTION;
--   SELECT * FROM Accounts WHERE account_id = 1;
--
-- SESSION B
--   SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--   UPDATE Accounts SET balance = 0 WHERE account_id = 1;
--   -- blocks until SESSION A COMMITs/ROLLBACKs (next-key locking)