
CREATE DATABASE IF NOT EXISTS logistics_analysis;
USE logistics_analysis;

DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS warehouses;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    city VARCHAR(80),
    state VARCHAR(80),
    customer_segment VARCHAR(40),
    signup_date DATE
);

CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(120) NOT NULL,
    city VARCHAR(80),
    state VARCHAR(80),
    capacity_units INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    order_date DATE NOT NULL,
    product_category VARCHAR(60),
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_pct DECIMAL(4,2) DEFAULT 0,
    order_status VARCHAR(30),
    payment_method VARCHAR(40),
    order_value DECIMAL(14,2),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    warehouse_id INT NOT NULL,
    ship_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE NULL,
    shipment_status VARCHAR(30),
    shipping_cost DECIMAL(10,2),
    courier VARCHAR(60),
    CONSTRAINT fk_shipments_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_shipments_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

