-- ============================================================
-- DBMS Laboratory File
-- Experiment 07 : Normalization from UNF to 3NF and BCNF
-- CO4
-- ============================================================
-- Aim: Given a denormalized Sales table, identify functional
--      dependencies and normalize step-by-step from UNF to 3NF
--      and BCNF. Verify lossless join and dependency
--      preservation using SQL queries.
-- ============================================================

DROP DATABASE IF EXISTS NormalizeDB;
CREATE DATABASE NormalizeDB;
USE NormalizeDB;

-- ============================================================
-- STEP 0 : UNF (Unnormalized Form) — repeating groups present
-- ============================================================
CREATE TABLE Sales_UNF (
    order_id       INT,
    order_date     DATE,
    customer_id    INT,
    customer_name  VARCHAR(50),
    customer_city  VARCHAR(30),
    product_ids    VARCHAR(50),   -- comma separated (repeating)
    product_names  VARCHAR(100),  -- comma separated
    quantities     VARCHAR(30),   -- comma separated
    unit_prices    VARCHAR(30),   -- comma separated
    seller_id      INT,
    seller_name    VARCHAR(50),
    seller_city    VARCHAR(30)
);

INSERT INTO Sales_UNF VALUES
(1,'2024-01-10',10,'Ravi', 'Delhi',  '101,102','Pen,Book','2,1','10,50', 1,'Stationers','Delhi'),
(2,'2024-02-15',11,'Priya','Mumbai', '102,103','Book,Bag','3,1','50,300',1,'Stationers','Delhi'),
(3,'2024-03-20',10,'Ravi', 'Delhi',  '103',    'Bag',     '2',  '300',   2,'BagsRUs',   'Mumbai'),
(4,'2024-04-05',12,'Amit', 'Chennai','101',    'Pen',     '5',  '10',    1,'Stationers','Delhi');

SELECT * FROM Sales_UNF;

-- ============================================================
-- STEP 1 : 1NF — every cell atomic; one row per (order, product)
-- ============================================================
CREATE TABLE Sales_1NF (
    order_id      INT,
    order_date    DATE,
    customer_id   INT,
    customer_name VARCHAR(50),
    customer_city VARCHAR(30),
    product_id    INT,
    product_name  VARCHAR(50),
    quantity      INT,
    unit_price    DECIMAL(10,2),
    seller_id     INT,
    seller_name   VARCHAR(50),
    seller_city   VARCHAR(30),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO Sales_1NF VALUES
(1,'2024-01-10',10,'Ravi', 'Delhi',  101,'Pen', 2,10,  1,'Stationers','Delhi'),
(1,'2024-01-10',10,'Ravi', 'Delhi',  102,'Book',1,50,  1,'Stationers','Delhi'),
(2,'2024-02-15',11,'Priya','Mumbai', 102,'Book',3,50,  1,'Stationers','Delhi'),
(2,'2024-02-15',11,'Priya','Mumbai', 103,'Bag', 1,300, 2,'BagsRUs',   'Mumbai'),
(3,'2024-03-20',10,'Ravi', 'Delhi',  103,'Bag', 2,300, 2,'BagsRUs',   'Mumbai'),
(4,'2024-04-05',12,'Amit', 'Chennai',101,'Pen', 5,10,  1,'Stationers','Delhi');

SELECT * FROM Sales_1NF;

-- ============================================================
-- STEP 2 : 2NF — remove partial dependencies
--   order_id  -> order_date, customer_id
--   product_id -> product_name, seller_id
-- Only full FD remains : (order_id, product_id) -> quantity, unit_price
-- ============================================================
CREATE TABLE Orders (
    order_id    INT PRIMARY KEY,
    order_date  DATE,
    customer_id INT
);

CREATE TABLE Products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(50),
    seller_id    INT
);

CREATE TABLE OrderLine (
    order_id   INT,
    product_id INT,
    quantity   INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO Orders   SELECT DISTINCT order_id, order_date, customer_id FROM Sales_1NF;
INSERT INTO Products SELECT DISTINCT product_id, product_name, seller_id FROM Sales_1NF;
INSERT INTO OrderLine SELECT order_id, product_id, quantity, unit_price FROM Sales_1NF;

-- ============================================================
-- STEP 3 : 3NF — remove transitive dependencies
--   order_id   -> customer_id  -> customer_name, customer_city
--   product_id -> seller_id    -> seller_name,  seller_city
-- ============================================================
CREATE TABLE Customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(50),
    customer_city VARCHAR(30)
);

CREATE TABLE Sellers (
    seller_id   INT PRIMARY KEY,
    seller_name VARCHAR(50),
    seller_city VARCHAR(30)
);

INSERT INTO Customers SELECT DISTINCT customer_id, customer_name, customer_city FROM Sales_1NF;
INSERT INTO Sellers   SELECT DISTINCT seller_id,   seller_name,   seller_city   FROM Sales_1NF;

-- ============================================================
-- STEP 4 : BCNF check
-- Every determinant is a superkey?
--   Orders     : {order_id}                PK       -> BCNF
--   Customers  : {customer_id}             PK       -> BCNF
--   Products   : {product_id}              PK       -> BCNF
--   Sellers    : {seller_id}               PK       -> BCNF
--   OrderLine  : {order_id, product_id}    PK       -> BCNF
-- No further decomposition required.
-- ============================================================

-- ============================================================
-- VERIFICATION 1 : Lossless join
-- Join all decomposed tables back; row count must equal OrderLine
-- ============================================================
SELECT COUNT(*) AS joined_rows
FROM   OrderLine ol
JOIN   Orders    o ON ol.order_id   = o.order_id
JOIN   Customers c ON o.customer_id = c.customer_id
JOIN   Products  p ON ol.product_id = p.product_id
JOIN   Sellers   s ON p.seller_id   = s.seller_id;

-- Full reconstruction (compare side-by-side with Sales_1NF)
SELECT ol.order_id, o.order_date, o.customer_id, c.customer_name, c.customer_city,
       ol.product_id, p.product_name, ol.quantity, ol.unit_price,
       s.seller_id, s.seller_name, s.seller_city
FROM   OrderLine ol
JOIN   Orders    o ON ol.order_id   = o.order_id
JOIN   Customers c ON o.customer_id = c.customer_id
JOIN   Products  p ON ol.product_id = p.product_id
JOIN   Sellers   s ON p.seller_id   = s.seller_id
ORDER  BY ol.order_id, ol.product_id;

-- ============================================================
-- VERIFICATION 2 : Dependency preservation
-- Every FD must be checkable within one table -> each query
-- below should return ZERO rows.
-- ============================================================
-- FD1: order_id -> order_date, customer_id
SELECT 'FD1 violated' AS msg, order_id
FROM   Orders GROUP BY order_id
HAVING COUNT(DISTINCT order_date) > 1 OR COUNT(DISTINCT customer_id) > 1;

-- FD2: customer_id -> customer_name, customer_city
SELECT 'FD2 violated' AS msg, customer_id
FROM   Customers GROUP BY customer_id
HAVING COUNT(DISTINCT customer_name) > 1 OR COUNT(DISTINCT customer_city) > 1;

-- FD3: product_id -> product_name, seller_id
SELECT 'FD3 violated' AS msg, product_id
FROM   Products GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1 OR COUNT(DISTINCT seller_id) > 1;

-- FD4: seller_id -> seller_name, seller_city
SELECT 'FD4 violated' AS msg, seller_id
FROM   Sellers GROUP BY seller_id
HAVING COUNT(DISTINCT seller_name) > 1 OR COUNT(DISTINCT seller_city) > 1;

-- FD5: (order_id, product_id) -> quantity, unit_price
SELECT 'FD5 violated' AS msg, order_id, product_id
FROM   OrderLine GROUP BY order_id, product_id
HAVING COUNT(DISTINCT quantity) > 1 OR COUNT(DISTINCT unit_price) > 1;