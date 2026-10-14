-- ============================================================
-- DBMS Laboratory File
-- Experiment 02 : Convert ER diagram to relational schema
-- CO1
-- ============================================================
-- Converts the e-commerce ER design into MySQL tables with
-- PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, ON DELETE CASCADE
-- and ON DELETE SET NULL. Referential integrity violations are
-- demonstrated at the end.
-- ============================================================

DROP DATABASE IF EXISTS EcommerceDB;
CREATE DATABASE EcommerceDB;
USE EcommerceDB;

-- ------------------------------------------------------------
-- 1. CUSTOMER
-- ------------------------------------------------------------
CREATE TABLE Customer (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(30)  NOT NULL,
    last_name     VARCHAR(30)  NOT NULL,
    email         VARCHAR(80)  NOT NULL UNIQUE,
    phone         VARCHAR(15),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. ADDRESS  (belongs to Customer, CASCADE on delete)
-- ------------------------------------------------------------
CREATE TABLE Address (
    address_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    line1         VARCHAR(80) NOT NULL,
    line2         VARCHAR(80),
    city          VARCHAR(40) NOT NULL,
    state         VARCHAR(40) NOT NULL,
    pincode       CHAR(6)     NOT NULL,
    CONSTRAINT fk_addr_cust
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. SELLER
-- ------------------------------------------------------------
CREATE TABLE Seller (
    seller_id     INT AUTO_INCREMENT PRIMARY KEY,
    seller_name   VARCHAR(60)  NOT NULL,
    email         VARCHAR(80)  NOT NULL UNIQUE,
    contact_no    VARCHAR(15),
    gst_number    CHAR(15)     UNIQUE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. CATEGORY  (self-referencing for sub-categories)
-- ------------------------------------------------------------
CREATE TABLE Category (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(40) NOT NULL UNIQUE,
    parent_id     INT,
    CONSTRAINT fk_cat_parent
        FOREIGN KEY (parent_id) REFERENCES Category(category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. PRODUCT  (superclass; specialized attributes in child tables)
-- ------------------------------------------------------------
CREATE TABLE Product (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_name  VARCHAR(80)  NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    stock_qty     INT           NOT NULL DEFAULT 0,
    seller_id     INT           NOT NULL,
    category_id   INT           NOT NULL,
    CONSTRAINT fk_prod_seller
        FOREIGN KEY (seller_id)   REFERENCES Seller(seller_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_prod_category
        FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Specialization tables (disjoint subtypes)
CREATE TABLE Electronics (
    product_id      INT PRIMARY KEY,
    warranty_months INT,
    voltage         VARCHAR(10),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Clothing (
    product_id INT PRIMARY KEY,
    size       VARCHAR(5),
    fabric     VARCHAR(30),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Grocery (
    product_id  INT PRIMARY KEY,
    expiry_date DATE,
    weight_kg   DECIMAL(6,2),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Books (
    product_id INT PRIMARY KEY,
    isbn       VARCHAR(20),
    author     VARCHAR(60),
    publisher  VARCHAR(60),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. ORDERS
-- ------------------------------------------------------------
CREATE TABLE Orders (
    order_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT  NOT NULL,
    address_id  INT,
    order_date  DATETIME DEFAULT CURRENT_TIMESTAMP,
    status      ENUM('PLACED','SHIPPED','DELIVERED','CANCELLED')
                DEFAULT 'PLACED',
    CONSTRAINT fk_order_cust
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_addr
        FOREIGN KEY (address_id)  REFERENCES Address(address_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. ORDER ITEM  (weak entity, composite PK)
-- ------------------------------------------------------------
CREATE TABLE OrderItem (
    order_id    INT NOT NULL,
    product_id  INT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    price_each  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id)   REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 8. PAYMENT  (1:1 with Orders)
-- ------------------------------------------------------------
CREATE TABLE Payment (
    payment_id    INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT NOT NULL UNIQUE,
    amount        DECIMAL(10,2) NOT NULL,
    method        ENUM('UPI','CARD','NETBANKING','COD') NOT NULL,
    paid_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 9. DELIVERY  (weak, 1:1 with Orders)
-- ------------------------------------------------------------
CREATE TABLE Delivery (
    delivery_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT NOT NULL UNIQUE,
    courier       VARCHAR(40),
    tracking_no   VARCHAR(40) UNIQUE,
    dispatched_at DATETIME,
    delivered_at  DATETIME,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- SAMPLE DATA
-- ============================================================
INSERT INTO Customer (first_name,last_name,email,phone) VALUES
('Aarav','Sharma','aarav@example.in','9876543210'),
('Diya','Patel','diya@example.in','9812345678'),
('Kabir','Reddy','kabir@example.in','9898989898');

INSERT INTO Address (customer_id,line1,line2,city,state,pincode) VALUES
(1,'12 MG Road','Near Metro','Bengaluru','Karnataka','560001'),
(1,'Plot 44','Sector 5','Pune','Maharashtra','411001'),
(2,'7 Park Street','Flat 3B','Kolkata','West Bengal','700016');

INSERT INTO Seller (seller_name,email,contact_no,gst_number) VALUES
('TechnoMart','sales@technomart.in','9000011111','29ABCDE1234F1Z5'),
('StyleHub','care@stylehub.in','9000022222','27XYZAB5678G1Z9'),
('BookBazaar','info@bookbazaar.in','9000033333','07LMNOP9012H1Z3');

INSERT INTO Category (category_name,parent_id) VALUES
('Electronics',NULL),
('Clothing',NULL),
('Books',NULL),
('Mobile Phones',1),
('Laptops',1);

INSERT INTO Product (product_name,unit_price,stock_qty,seller_id,category_id) VALUES
('Smartphone X',   25999.00, 40, 1, 4),
('Laptop Pro 14',  78999.00, 15, 1, 5),
('Cotton T-Shirt',   799.00,200, 2, 2),
('Novel - Winds',    499.00,120, 3, 3);

INSERT INTO Electronics (product_id,warranty_months,voltage) VALUES
(1,12,'5V'),(2,24,'19V');

INSERT INTO Clothing (product_id,size,fabric) VALUES
(3,'M','Cotton');

INSERT INTO Books (product_id,isbn,author,publisher) VALUES
(4,'978-81-1234-567-8','R. Menon','Penguin India');

INSERT INTO Orders (customer_id,address_id,status) VALUES
(1,1,'PLACED'),
(2,3,'SHIPPED'),
(3,1,'DELIVERED');

INSERT INTO OrderItem (order_id,product_id,quantity,price_each) VALUES
(1,1,1,25999.00),
(1,3,2, 799.00),
(2,2,1,78999.00),
(3,4,3, 499.00);

INSERT INTO Payment (order_id,amount,method) VALUES
(1,27597.00,'UPI'),
(2,78999.00,'CARD'),
(3,1497.00,'COD');

INSERT INTO Delivery (order_id,courier,tracking_no) VALUES
(1,'BlueDart','BD123456'),
(2,'Delhivery','DL998877'),
(3,'IndiaPost','IP112233');

-- ============================================================
-- REFERENTIAL INTEGRITY VIOLATIONS (each should FAIL)
-- ============================================================
-- 1. Insert Address for a non-existent customer
--    Expected: ERROR 1452 - FK constraint fails
INSERT INTO Address (customer_id,line1,city,state,pincode)
VALUES (999,'Fake St','Nowhere','NA','000000');

-- 2. Insert Product with a non-existent seller
--    Expected: ERROR 1452 - FK constraint fails
INSERT INTO Product (product_name,unit_price,stock_qty,seller_id,category_id)
VALUES ('Ghost Item',100,5,999,1);

-- 3. Insert OrderItem referencing a non-existent order
--    Expected: ERROR 1452 - FK constraint fails
INSERT INTO OrderItem (order_id,product_id,quantity,price_each)
VALUES (999,1,1,100);

-- 4. Duplicate email in Customer  (UNIQUE violation)
--    Expected: ERROR 1062 - Duplicate entry
INSERT INTO Customer (first_name,last_name,email,phone)
VALUES ('Test','User','aarav@example.in','9000000000');

-- 5. Delete a Seller who still has products
--    Expected: ERROR 1451 - Cannot delete parent row
DELETE FROM Seller WHERE seller_id = 1;

-- ============================================================
-- ON DELETE CASCADE / SET NULL demonstration
-- ============================================================
-- Delete customer 1 → Address and Orders belonging to that
-- customer are automatically removed.
-- DELETE FROM Customer WHERE customer_id = 1;

-- Delete address 1 → Orders.address_id becomes NULL.
-- DELETE FROM Address WHERE address_id = 1;

-- ============================================================
-- END OF EXPERIMENT 02
-- ============================================================