-- ============================================================
-- DBMS Laboratory File
-- Experiment 09 : Railway Booking — Index Benchmarking
-- CO5
-- ============================================================
-- Aim: Create a Railway Booking table with at least 5,000
--      records. Benchmark query performance before and after
--      creating single and composite indexes. Use EXPLAIN to
--      compare execution plans.
-- ============================================================

DROP DATABASE IF EXISTS RailwayDB;
CREATE DATABASE RailwayDB;
USE RailwayDB;

-- ------------------------------------------------------------
-- Helper : digits 0..9 for cross-join row generation
-- ------------------------------------------------------------
CREATE TABLE digits (d INT);
INSERT INTO digits VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- ------------------------------------------------------------
-- Railway Booking table
-- ------------------------------------------------------------
CREATE TABLE Railway (
    booking_id     INT PRIMARY KEY,
    passenger_name VARCHAR(50),
    train_no       VARCHAR(10),
    train_name     VARCHAR(50),
    source_station VARCHAR(30),
    dest_station   VARCHAR(30),
    travel_date    DATE,
    seat_class     VARCHAR(10),
    fare           DECIMAL(10,2),
    booking_status VARCHAR(20)
);

-- ------------------------------------------------------------
-- Generate 5000 rows (cross join of 4 digits tables)
-- booking_id = d1*1000 + d2*100 + d3*10 + d4 + 1
-- ------------------------------------------------------------
INSERT INTO Railway
    (booking_id, passenger_name, train_no, train_name, source_station,
     dest_station, travel_date, seat_class, fare, booking_status)
SELECT
    d1.d*1000 + d2.d*100 + d3.d*10 + d4.d + 1                              AS booking_id,
    CONCAT('Passenger_', LPAD(d1.d*1000 + d2.d*100 + d3.d*10 + d4.d + 1,5,'0')),
    CONCAT('T', LPAD((d1.d*10 + d2.d) % 200 + 1, 4, '0'))                  AS train_no,
    CONCAT('Train_', LPAD((d1.d*10 + d2.d) % 200 + 1, 4, '0'))             AS train_name,
    ELT(d3.d + 1, 'Delhi','Mumbai','Chennai','Kolkata','Bengaluru',
                  'Pune','Hyderabad','Ahmedabad','Jaipur','Lucknow')       AS source_station,
    ELT(((d3.d + 3) % 10) + 1,
                  'Delhi','Mumbai','Chennai','Kolkata','Bengaluru',
                  'Pune','Hyderabad','Ahmedabad','Jaipur','Lucknow')       AS dest_station,
    DATE_ADD('2024-01-01', INTERVAL ((d2.d*10 + d4.d) % 365) DAY)          AS travel_date,
    ELT((d4.d % 3) + 1, 'Sleeper','3AC','2AC')                             AS seat_class,
    ROUND(500 + (d4.d * 30) + (d2.d * 5), 2)                               AS fare,
    IF((d1.d*10 + d4.d) % 7 = 0, 'Cancelled', 'Confirmed')                 AS booking_status
FROM digits d1
CROSS JOIN digits d2
CROSS JOIN digits d3
CROSS JOIN digits d4
ORDER BY booking_id
LIMIT 5000;

SELECT COUNT(*) AS total_rows FROM Railway;

-- ============================================================
-- BENCHMARK 1 : query by (train_no + source_station)
-- ============================================================
-- BEFORE INDEX
SET @t0 = NOW(6);
SELECT COUNT(*), SUM(fare)
FROM   Railway
WHERE  train_no = 'T0015'
  AND  source_station = 'Delhi';
SELECT TIMEDIFF(NOW(6), @t0) AS elapsed_before;

EXPLAIN
SELECT COUNT(*), SUM(fare)
FROM   Railway
WHERE  train_no = 'T0015' AND source_station = 'Delhi';

-- AFTER SINGLE INDEX on train_no
CREATE INDEX idx_train_no ON Railway(train_no);

EXPLAIN
SELECT COUNT(*), SUM(fare)
FROM   Railway
WHERE  train_no = 'T0015' AND source_station = 'Delhi';

-- AFTER COMPOSITE INDEX (train_no, source_station) — covering
CREATE INDEX idx_train_src ON Railway(train_no, source_station);

EXPLAIN
SELECT COUNT(*), SUM(fare)
FROM   Railway
WHERE  train_no = 'T0015' AND source_station = 'Delhi';

-- ============================================================
-- BENCHMARK 2 : query by (travel_date + seat_class)
-- ============================================================
SET @t0 = NOW(6);
SELECT COUNT(*) FROM Railway
WHERE  travel_date BETWEEN '2024-06-01' AND '2024-06-30'
  AND  seat_class  = '3AC';
SELECT TIMEDIFF(NOW(6), @t0) AS elapsed_before;

EXPLAIN
SELECT COUNT(*) FROM Railway
WHERE  travel_date BETWEEN '2024-06-01' AND '2024-06-30' AND seat_class = '3AC';

-- Add composite index
CREATE INDEX idx_travel_class ON Railway(travel_date, seat_class);

EXPLAIN
SELECT COUNT(*) FROM Railway
WHERE  travel_date BETWEEN '2024-06-01' AND '2024-06-30' AND seat_class = '3AC';

-- ============================================================
-- BENCHMARK 3 : query by passenger_name prefix
-- ============================================================
EXPLAIN
SELECT * FROM Railway WHERE passenger_name LIKE 'Passenger_00001%';

CREATE INDEX idx_passenger ON Railway(passenger_name);

EXPLAIN
SELECT * FROM Railway WHERE passenger_name LIKE 'Passenger_00001%';

-- ============================================================
-- BENCHMARK 4 : ORDER BY + LIMIT
-- ============================================================
EXPLAIN
SELECT booking_id, travel_date, fare
FROM   Railway
ORDER  BY travel_date DESC
LIMIT  100;

CREATE INDEX idx_travel_date ON Railway(travel_date);

EXPLAIN
SELECT booking_id, travel_date, fare
FROM   Railway
ORDER  BY travel_date DESC
LIMIT  100;

-- ============================================================
-- SHOW INDEXES CREATED
-- ============================================================
SHOW INDEX FROM Railway;