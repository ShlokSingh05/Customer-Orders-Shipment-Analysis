-- 20+ business questions for MySQL 8.0+
USE logistics_analysis;

-- 1. Total orders, revenue, and average order value
SELECT COUNT(*) AS total_orders,
       ROUND(SUM(order_value), 2) AS total_revenue,
       ROUND(AVG(order_value), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';

-- 2. Revenue by product category
SELECT product_category, ROUND(SUM(order_value),2) AS revenue
FROM orders WHERE order_status <> 'Cancelled'
GROUP BY product_category ORDER BY revenue DESC;

-- 3. Monthly order volume and revenue
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
       COUNT(*) AS orders_count, ROUND(SUM(order_value),2) AS revenue
FROM orders WHERE order_status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

-- 4. Top 10 customers by revenue
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS orders_count,
       ROUND(SUM(o.order_value),2) AS revenue
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC LIMIT 10;

-- 5. Customer segment performance
SELECT c.customer_segment, COUNT(o.order_id) AS order_count,
       ROUND(SUM(o.order_value),2) AS revenue,
       ROUND(AVG(o.order_value),2) AS avg_order_value
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_segment ORDER BY revenue DESC;

-- 6. Orders by payment method
SELECT payment_method, COUNT(*) AS order_count,
       ROUND(SUM(order_value),2) AS gross_order_value
FROM orders GROUP BY payment_method ORDER BY order_count DESC;

-- 7. Warehouse order volume and revenue
SELECT w.warehouse_name, w.city, COUNT(o.order_id) AS order_count,
       ROUND(SUM(o.order_value),2) AS revenue
FROM warehouses w LEFT JOIN orders o ON w.warehouse_id=o.warehouse_id
GROUP BY w.warehouse_id,w.warehouse_name,w.city
ORDER BY order_count DESC;

-- 8. Courier shipment count and average shipping cost
SELECT courier, COUNT(*) AS shipments,
       ROUND(AVG(shipping_cost),2) AS avg_shipping_cost
FROM shipments GROUP BY courier ORDER BY shipments DESC;

-- 9. Delivered orders that arrived after expected date
SELECT s.shipment_id, s.order_id, s.courier, s.expected_delivery_date,
       s.actual_delivery_date,
       DATEDIFF(s.actual_delivery_date,s.expected_delivery_date) AS days_late
FROM shipments s
WHERE s.actual_delivery_date > s.expected_delivery_date
ORDER BY days_late DESC;

-- 10. Delay rate among delivered shipments
SELECT COUNT(*) AS delivered_shipments,
       SUM(actual_delivery_date > expected_delivery_date) AS delayed_shipments,
       ROUND(100.0 * SUM(actual_delivery_date > expected_delivery_date) / NULLIF(COUNT(*),0),2) AS delay_pct
FROM shipments WHERE shipment_status='Delivered' AND actual_delivery_date IS NOT NULL;

-- 11. Delay rate by courier
SELECT courier, COUNT(*) AS delivered_shipments,
       SUM(actual_delivery_date > expected_delivery_date) AS delayed_shipments,
       ROUND(100.0*SUM(actual_delivery_date > expected_delivery_date)/NULLIF(COUNT(*),0),2) AS delay_pct
FROM shipments
WHERE shipment_status='Delivered' AND actual_delivery_date IS NOT NULL
GROUP BY courier ORDER BY delay_pct DESC;

-- 12. Delay rate by warehouse
SELECT w.warehouse_name, COUNT(s.shipment_id) AS delivered_shipments,
       SUM(s.actual_delivery_date > s.expected_delivery_date) AS delayed_shipments,
       ROUND(100.0*SUM(s.actual_delivery_date > s.expected_delivery_date)/NULLIF(COUNT(s.shipment_id),0),2) AS delay_pct
FROM warehouses w JOIN shipments s ON w.warehouse_id=s.warehouse_id
WHERE s.shipment_status='Delivered' AND s.actual_delivery_date IS NOT NULL
GROUP BY w.warehouse_id,w.warehouse_name ORDER BY delay_pct DESC;

-- 13. Customers with at least 5 orders (HAVING)
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS order_count
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(o.order_id)>=5 ORDER BY order_count DESC;

-- 14. Orders above the overall average order value (subquery)
SELECT order_id, customer_id, order_value
FROM orders
WHERE order_value > (SELECT AVG(order_value) FROM orders)
ORDER BY order_value DESC;

-- 15. Category revenue above average category revenue (CTE)
WITH category_revenue AS (
    SELECT product_category, SUM(order_value) AS revenue
    FROM orders WHERE order_status <> 'Cancelled'
    GROUP BY product_category
)
SELECT product_category, ROUND(revenue,2) AS revenue
FROM category_revenue
WHERE revenue > (SELECT AVG(revenue) FROM category_revenue)
ORDER BY revenue DESC;

-- 16. Rank customers by revenue using a window function
WITH customer_revenue AS (
    SELECT c.customer_id,c.customer_name,SUM(o.order_value) AS revenue
    FROM customers c JOIN orders o ON c.customer_id=o.customer_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.customer_id,c.customer_name
)
SELECT customer_id,customer_name,ROUND(revenue,2) AS revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_revenue ORDER BY revenue_rank LIMIT 20;

-- 17. Cancelled order percentage by product category
SELECT product_category, COUNT(*) AS total_orders,
       SUM(order_status='Cancelled') AS cancelled_orders,
       ROUND(100.0*SUM(order_status='Cancelled')/COUNT(*),2) AS cancellation_pct
FROM orders GROUP BY product_category ORDER BY cancellation_pct DESC;

-- 18. Average time from order to shipment
SELECT ROUND(AVG(DATEDIFF(s.ship_date,o.order_date)),2) AS avg_days_to_ship
FROM orders o JOIN shipments s ON o.order_id=s.order_id
WHERE s.ship_date IS NOT NULL;

-- 19. Monthly delivered shipment delay trend
SELECT DATE_FORMAT(actual_delivery_date,'%Y-%m') AS delivery_month,
       COUNT(*) AS delivered_count,
       SUM(actual_delivery_date > expected_delivery_date) AS delayed_count,
       ROUND(100.0*SUM(actual_delivery_date > expected_delivery_date)/COUNT(*),2) AS delay_pct
FROM shipments
WHERE shipment_status='Delivered' AND actual_delivery_date IS NOT NULL
GROUP BY DATE_FORMAT(actual_delivery_date,'%Y-%m')
ORDER BY delivery_month;

-- 20. Orders with shipment details (JOIN across four tables)
SELECT o.order_id,c.customer_name,o.order_date,o.product_category,o.order_value,
       w.warehouse_name,s.courier,s.shipment_status,s.expected_delivery_date,s.actual_delivery_date
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
JOIN warehouses w ON o.warehouse_id=w.warehouse_id
LEFT JOIN shipments s ON o.order_id=s.order_id
ORDER BY o.order_date DESC LIMIT 100;

-- 21. Customers who have never placed an order
SELECT c.customer_id,c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_id IS NULL;

-- 22. Shipping cost as a share of order value by courier
SELECT s.courier,
       ROUND(AVG(s.shipping_cost),2) AS avg_shipping_cost,
       ROUND(AVG(o.order_value),2) AS avg_order_value,
       ROUND(100*AVG(s.shipping_cost/NULLIF(o.order_value,0)),2) AS avg_shipping_cost_pct
FROM shipments s JOIN orders o ON s.order_id=o.order_id
GROUP BY s.courier ORDER BY avg_shipping_cost_pct DESC;

-- 23. Warehouse with the highest delayed shipment count
SELECT w.warehouse_name,
       SUM(s.actual_delivery_date > s.expected_delivery_date) AS delayed_shipments
FROM warehouses w JOIN shipments s ON w.warehouse_id=s.warehouse_id
WHERE s.shipment_status='Delivered' AND s.actual_delivery_date IS NOT NULL
GROUP BY w.warehouse_id,w.warehouse_name
ORDER BY delayed_shipments DESC LIMIT 1;

-- 24. Order status distribution
SELECT order_status,COUNT(*) AS order_count,
       ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM orders),2) AS order_pct
FROM orders GROUP BY order_status ORDER BY order_count DESC;

-- 25. Find customers whose revenue is above their segment's average (CTE)
WITH customer_spend AS (
    SELECT c.customer_id,c.customer_name,c.customer_segment,
           SUM(o.order_value) AS revenue
    FROM customers c JOIN orders o ON c.customer_id=o.customer_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.customer_id,c.customer_name,c.customer_segment
),
segment_avg AS (
    SELECT customer_segment,AVG(revenue) AS avg_revenue
    FROM customer_spend GROUP BY customer_segment
)
SELECT cs.customer_id,cs.customer_name,cs.customer_segment,
       ROUND(cs.revenue,2) AS revenue,ROUND(sa.avg_revenue,2) AS segment_avg_revenue
FROM customer_spend cs JOIN segment_avg sa ON cs.customer_segment=sa.customer_segment
WHERE cs.revenue > sa.avg_revenue
ORDER BY cs.revenue DESC;
