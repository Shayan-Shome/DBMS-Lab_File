# Experiment 02 — Relational Schema & Referential Integrity

**Aim:** Convert the ER diagram into a relational schema. Write complete MySQL CREATE TABLE statements with primary keys, foreign keys, NOT NULL, UNIQUE, ON DELETE CASCADE and SET NULL constraints. Insert sample data and demonstrate referential integrity violations.

**Course Outcome:** CO1

## Files
| File                | Description                                           |
| ------------------- | ----------------------------------------------------- |
| `Experiment-02.sql` | Full schema + sample data + integrity violation tests |
| `Experiment-02.pdf` | Lab-file scan                                         |

## Tables Created (13)
Customer, Address, Seller, Category, Product, Electronics, Clothing, Grocery, Books, Orders, OrderItem, Payment, Delivery.

## Key Constraint Choices
- `ON DELETE CASCADE` → Address↔Customer, OrderItem↔Orders, Payment↔Orders, Delivery↔Orders, subtype tables↔Product.
- `ON DELETE SET NULL` → Orders.address_id ↔ Address, Category.parent_id ↔ Category.
- `ON DELETE RESTRICT` → Product.seller_id, Product.category_id (do not allow deleting a seller/category that still has products).
- `UNIQUE` on Customer.email, Seller.email, Seller.gst_number, Payment.order_id, Delivery.order_id, Delivery.tracking_no.

## Referential Integrity Violations Demonstrated
1. Address with non-existent customer → **ERROR 1452**
2. Product with non-existent seller → **ERROR 1452**
3. OrderItem with non-existent order → **ERROR 1452**
4. Duplicate email → **ERROR 1062**
5. Delete seller who still sells products → **ERROR 1451**

## Status
- [x] Schema created
- [x] Sample data inserted
- [x] Violations tested
- [x] PDF scanned and placed