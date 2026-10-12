# Customer, Orders & Shipment Analysis (MySQL)

A portfolio-ready SQL analytics project that explores customer behavior, order revenue, warehouse performance, and shipment delivery delays.

## Project overview
- **Database:** MySQL 8.0+
- **Tables:** customers, orders, warehouses, shipments
- **Rows supplied:** 1,000 customers + 3,000 orders + 10 warehouses + 3,000 shipments = **7,010 records**
- **SQL concepts:** joins, CTEs, subqueries, aggregate functions, `GROUP BY`, `HAVING`, date functions, conditional aggregation, and window functions
- **Business questions:** 25 included

> This is a synthetic practice dataset created for portfolio and learning purposes. Treat any findings as results from the sample data, not real company performance.

## Business objectives
1. Understand order volume, revenue, and average order value.
2. Compare category, customer segment, payment method, and warehouse performance.
3. Measure shipment delays overall and by courier, warehouse, and month.
4. Identify high-value customers and orders that need operational attention.
5. Review cancellation patterns and shipping cost.

## Repository structure
```text
Customer_Orders_Shipment_Analysis/
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   ├── warehouses.csv
│   └── shipments.csv
├── sql/
│   ├── 01_schema.sql
│   └── 02_business_analysis_queries.sql
└── README.md
```

## Setup instructions (MySQL Workbench)
1. Install/start MySQL Server and open MySQL Workbench.
2. Open and run `sql/01_schema.sql` to create the database and tables.
3. Import the CSV files into their matching tables using **Table Data Import Wizard**. Import `customers` and `warehouses` first, then `orders`, then `shipments`.
4. Check row counts:
   ```sql
   USE logistics_analysis;
   SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
   UNION ALL SELECT 'orders', COUNT(*) FROM orders
   UNION ALL SELECT 'warehouses', COUNT(*) FROM warehouses
   UNION ALL SELECT 'shipments', COUNT(*) FROM shipments;
   ```
5. Open and run `sql/02_business_analysis_queries.sql` query by query.

### CSV import notes
- Keep the CSV column names and order unchanged.
- The `orders.csv` file includes a calculated `order_value` column.
- Empty `actual_delivery_date` values are expected for shipments that are not marked delivered.
- If MySQL Workbench does not infer date columns correctly, set date columns to `DATE` and decimal columns to `DECIMAL` during import.

## Data dictionary
| Table | Purpose | Key fields |
|---|---|---|
| `customers` | Customer profiles and segments | `customer_id`, `customer_segment`, `city`, `state` |
| `orders` | Order details and commercial value | `order_id`, `customer_id`, `warehouse_id`, `order_date`, `order_value`, `order_status` |
| `warehouses` | Distribution center details | `warehouse_id`, `city`, `capacity_units` |
| `shipments` | Carrier, shipping cost, and delivery dates | `shipment_id`, `order_id`, `courier`, `expected_delivery_date`, `actual_delivery_date` |

## Key metric definitions
- **Revenue:** Sum of `order_value` for orders excluding cancelled orders where noted.
- **Average order value (AOV):** Average `order_value`; specify status filters when comparing results.
- **Delayed delivered shipment:** `actual_delivery_date > expected_delivery_date`, among shipments marked `Delivered` with a non-null actual delivery date.
- **Delay rate:** Delayed delivered shipments divided by delivered shipments with an actual delivery date.

## SQL analysis included
The query file contains 25 questions, including:
- Revenue by category and month
- Top customers and customer segment performance
- Warehouse and courier comparisons
- Delivered shipment delays and delay percentages
- CTE-based category and customer-segment comparisons
- Customer revenue ranking with `DENSE_RANK()`
- Cancelled orders and customers without orders
- Four-table joined order/shipment detail

## Important interpretation note
The sample generator intentionally includes some late deliveries. The exact delay rate is calculated from the imported rows by query 10; do not state a fixed 10–20% result on your résumé unless your executed query confirms it.

## Suggested résumé bullets
Use the real results after running the SQL queries:
- Analyzed **7,010+ records** across four related MySQL tables to evaluate customer, order, warehouse, and shipment performance.
- Applied joins, CTEs, subqueries, aggregate functions, and window functions to answer **25 business questions** covering revenue, cancellations, and delivery operations.
- Measured shipment delay rates by courier and warehouse to highlight potential delivery bottlenecks.

## Skills demonstrated
MySQL · Relational Data Modeling · Data Analysis · Business Reporting · Data Quality Checks · Logistics Analytics
