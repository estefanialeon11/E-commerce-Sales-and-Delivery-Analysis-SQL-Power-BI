CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_zip_code_prefix INT,
	customer_city VARCHAR(100),
	customer_state VARCHAR(50)
);

CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category_name VARCHAR(100),
	product_weight_g DECIMAL(10,1),
	product_length_cm DECIMAL(10,1),
	product_height_cm DECIMAL(10,1),
	product_width_cm DECIMAL(10,1)
);

CREATE TABLE orders (
	order_id VARCHAR(50) PRIMARY KEY,
	customer_id VARCHAR(50),
	order_status VARCHAR(50),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_timestamp TIMESTAMP,
	order_estimated_delivery_date DATE
);

CREATE TABLE orderitems (
	order_id VARCHAR(50),
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	price DECIMAL(10,2),
	shipping_charges DECIMAL(10,2),
	PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
	order_id VARCHAR(50),
	payment_sequential INT,
	payment_type VARCHAR(100),
	payment_installments INT,
	payment_value DECIMAL(10,2),
	PRIMARY KEY (order_id, payment_sequential)
);

SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET order_delivered_timestamp = NULL
WHERE order_delivered_timestamp = '';

UPDATE orders
SET order_delivered_timestamp = NULL
WHERE STR_TO_DATE(order_delivered_timestamp, '%Y-%m-%d %H:%i:%s') IS NULL;

ALTER TABLE orders
MODIFY order_delivered_timestamp DATETIME;

SET SQL_SAFE_UPDATES = 1;

SELECT o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

SELECT oi.order_id
FROM orderitems oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

DELETE oi
FROM orderitems oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

ALTER TABLE orderitems
ADD CONSTRAINT fk_orderitems_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

SELECT oi.product_id
FROM orderitems oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

DELETE oi
FROM orderitems oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

ALTER TABLE orderitems
ADD CONSTRAINT fk_orderitems_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

SELECT p.order_id

FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

DELETE p
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

ALTER TABLE payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM orderitems;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM customers;

-- 1. Total de órdenes
SELECT COUNT(*) AS total_orders
FROM orders;

-- 2. Total de clientes únicos que compraron
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- 3. Ingreso total generado
SELECT ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- 4. Pago promedio por orden
SELECT ROUND(AVG(payment_value), 2) AS avg_payment
FROM payments;

-- 5. Cantidad de órdenes por estado
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 6. Órdenes por mes
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
       COUNT(*) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY month;

-- 7. Top 10 productos más vendidos
SELECT product_id, COUNT(*) AS times_sold
FROM orderitems
GROUP BY product_id
ORDER BY times_sold DESC
LIMIT 10;

-- 8. Valor total pagado por tipo de pago
SELECT payment_type,
       COUNT(*) AS total_transactions,
       ROUND(SUM(payment_value), 2) AS total_paid
FROM payments
GROUP BY payment_type
ORDER BY total_paid DESC;