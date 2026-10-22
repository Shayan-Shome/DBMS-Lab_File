-- ============================================================
-- DBMS Laboratory File
-- Experiment 10 : Query Optimization on 10,000-row dataset
-- CO5
-- ============================================================
-- Aim: Generate a dataset with at least 10,000 rows. Write
--      five slow queries, analyze using EXPLAIN, optimize using
--      indexing and query rewriting, and compare execution time
--      before and after optimization.
-- ============================================================

DROP DATABASE IF EXISTS QueryOptDB;
CREATE DATABASE QueryOptDB;
USE QueryOptDB;

CREATE TABLE digits (d INT);
INSERT INTO digits VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- ------------------------------------------------------------
-- 10,000-row dataset
-- ------------------------------------------------------------
CREATE TABLE OnlineSales (
    sale_id        INT PRIMARY KEY,
    customer_id    INT NOT NULL,
    product_id     INT NOT NULL,
    seller_id      INT NOT NULL,
    sale_date      DATE NOT NULL,
    region         VARCHAR(20) NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,
    discount       DECIMAL(5,2) DEFAULT 0,
    payment_method VARCHAR(20),
    status         VARCHAR(20)
);

INSERT INTO OnlineSales
SELECT
    n,
    (n % 1000) + 1,
    (n % 500) + 1,
    (n % 50) + 1,
    DATE_ADD('2023-01-01', INTERVAL (n*7) % 730 DAY),
    ELT((n % 5) + 1, 'North','South','East','West','Central'),
    ROUND(100 + (n % 5000) * 1.5, 2),
    ROUND((n % 30) * 0.5, 2),
    ELT((n % 4) + 1, 'UPI','CARD','NETBANKING','COD'),
    IF((n % 6) = 0, 'Cancelled', 'Delivered')
FROM (
    SELECT d1.d*1000 + d2.d*100 + d3.d*10 + d4.d + 1 AS n
    FROM digits d1
    CROSS JOIN digits d2
    CROSS JOIN digits d3
    CROSS JOIN digits d4
    WHERE d1.d*1000 + d2.d*100 + d3.d*10 + d4.d + 1 <= 10000
) AS gen;

SELECT COUNT(*) AS total_rows FROM OnlineSales;

-- ============================================================
-- QUERY 1 : function on indexed column — YEAR()
-- ============================================================
-- SLOW (function wraps column → index unusable)
SET @t0 = NOW(6);
SELECT COUNT(*), SUM(amount)
FROM   OnlineSales
WHERE  YEAR(sale_date) = 2024
  AND  region = 'North';
SELECT TIMEDIFF(NOW(6), @t0) AS q1_before;

EXPLAIN
SELECT COUNT(*), SUM(amount)
FROM   OnlineSales
WHERE  YEAR(sale_date) = 2024 AND region = 'North';

-- OPTIMIZED: rewrite to range + add composite index
CREATE INDEX idx_region_date ON OnlineSales(region, sale_date);

SET @t0 = NOW(6);
SELECT COUNT(*), SUM(amount)
FROM   OnlineSales
WHERE  sale_date >= '2024-01-01'
  AND  sale_date <  '2025-01-01'
  AND  region = 'North';
SELECT TIMEDIFF(NOW(6), @t0) AS q1_after;

EXPLAIN
SELECT COUNT(*), SUM(amount)
FROM   OnlineSales
WHERE  sale_date >= '2024-01-01' AND sale_date < '2025-01-01' AND region = 'North';

-- ============================================================
-- QUERY 2 : filter on two non-indexed columns
-- ============================================================
SET @t0 = NOW(6);
SELECT COUNT(*) FROM OnlineSales
WHERE  status = 'Delivered'
  AND  amount > 5000;
SELECT TIMEDIFF(NOW(6), @t0) AS q2_before;

EXPLAIN
SELECT COUNT(*) FROM OnlineSales
WHERE  status = 'Delivered' AND amount > 5000;

CREATE INDEX idx_status_amount ON OnlineSales(status, amount);

SET @t0 = NOW(6);
SELECT COUNT(*) FROM OnlineSales
WHERE  status = 'Delivered'
  AND  amount > 5000;
SELECT TIMEDIFF(NOW(6), @t0) AS q2_after;

EXPLAIN
SELECT COUNT(*) FROM OnlineSales
WHERE  status = 'Delivered' AND amount > 5000;

-- ============================================================
-- QUERY 3 : IN + correlated subquery (rewrite as JOIN)
-- ============================================================
SET @t0 = NOW(6);
SELECT COUNT(*) FROM OnlineSales
WHERE  customer_id IN (
    SELECT customer_id FROM OnlineSales WHERE region = 'North'
);
SELECT TIMEDIFF(NOW(6), @t0) AS q3_before;

EXPLAIN
SELECT COUNT(*) FROM OnlineSales
WHERE  customer_id IN (
    SELECT customer_id FROM OnlineSales WHERE region = 'North'
);

-- OPTIMIZED: JOIN with DISTINCT set
CREATE INDEX idx_region_customer ON OnlineSales(region, customer_id);

SET @t0 = NOW(6);
SELECT COUNT(*) FROM OnlineSales s
JOIN   (SELECT DISTINCT customer_id FROM OnlineSales WHERE region = 'North') n
  ON   s.customer_id = n.customer_id;
SELECT TIMEDIFF(NOW(6), @t0) AS q3_after;

EXPLAIN
SELECT COUNT(*) FROM OnlineSales s
JOIN   (SELECT DISTINCT customer_id FROM OnlineSales WHERE region = 'North') n
  ON   s.customer_id = n.customer_id;

-- ============================================================
-- QUERY 4 : ORDER BY on un-indexed column
-- ============================================================
SET @t0 = NOW(6);
SELECT sale_id, sale_date, amount
FROM   OnlineSales
ORDER  BY sale_date DESC
LIMIT  100;
SELECT TIMEDIFF(NOW(6), @t0) AS q4_before;

EXPLAIN
SELECT sale_id, sale_date, amount
FROM   OnlineSales
ORDER  BY sale_date DESC
LIMIT  100;

CREATE INDEX idx_sale_date ON OnlineSales(sale_date);

SET @t0 = NOW(6);
SELECT sale_id, sale_date, amount
FROM   OnlineSales
ORDER  BY sale_date DESC
LIMIT  100;
SELECT TIMEDIFF(NOW(6), @t0) AS q4_after;

EXPLAIN
SELECT sale_id, sale_date, amount
FROM   OnlineSales
ORDER  BY sale_date DESC
LIMIT  100;

-- ============================================================
-- QUERY 5 : leading-wildcard LIKE + COUNT(DISTINCT)
-- ============================================================
SET @t0 = NOW(6);
SELECT COUNT(DISTINCT customer_id)
FROM   OnlineSales
WHERE  payment_method LIKE '%CARD%';
SELECT TIMEDIFF(NOW(6), @t0) AS q5_before;

EXPLAIN
SELECT COUNT(DISTINCT customer_id)
FROM   OnlineSales
WHERE  payment_method LIKE '%CARD%';

-- OPTIMIZED: exact match (data normalised upstream) + covering index
CREATE INDEX idx_pm_customer ON OnlineSales(payment_method, customer_id);

SET @t0 = NOW(6);
SELECT COUNT(DISTINCT customer_id)
FROM   OnlineSales
WHERE  payment_method = 'CARD';
SELECT TIMEDIFF(NOW(6), @t0) AS q5_after;

EXPLAIN
SELECT COUNT(DISTINCT customer_id)
FROM   OnlineSales
WHERE  payment_method = 'CARD';

-- ============================================================
-- FINAL : list all indexes
-- ============================================================
SHOW INDEX FROM OnlineSales;