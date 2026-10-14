# Experiment 01 — ER Diagram (Indian E-commerce Platform)

**Aim:** Design an ER diagram for an Indian e-commerce platform with the entities Customer, Product, Order, OrderItem, Seller, Category, Payment, Delivery, Address. Specify primary keys, composite and multi-valued attributes, weak entities, specialization of Product, and participation constraints.

**Course Outcome:** CO1

## Files
| File                | Description                                                 |
| ------------------- | ----------------------------------------------------------- |
| `Experiment-01.sql` | Textual specification of the ER diagram (no executable SQL) |
| `Experiment-01.pdf` | Hand-drawn ER diagram scan                                  |

## Diagram Summary

**Entities (9):** Customer, Product, Order, OrderItem, Seller, Category, Payment, Delivery, Address.

**Weak entities:** OrderItem (owner: Order), Delivery (owner: Order).

**Composite attributes:** name → (first, last), phone → (country code, number), address → (line1, line2, city, state, pincode).

**Multi-valued attributes:** Customer.email, Customer.phone, Seller.contact_no.

**Specialization:** Product is specialized (disjoint) into Electronics, Clothing, Grocery, Books.

**Participation:** Order, Payment, Delivery, Address have total participation where required; Product has partial participation in OrderItem.

## Status
- [x] ER diagram drawn
- [x] PDF scanned and placed
- [x] Committed