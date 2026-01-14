-- 1. Sales
-- How many orders and how much revenue were there per month?
SELECT EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
	COUNT(o.order_id) AS orders,
	SUM(p.payment_value) AS revenue
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id
GROUP BY month;

SELECT COUNT(o.order_id) AS orders, SUM(p.payment_value) AS revenue
FROM orders o LEFT JOIN payments p ON o.order_id = p.order_id

-- Which states (customer_state) generate the most sales?

SELECT  s.seller_state AS state,
	COUNT(o.order_id) AS orders, 
	SUM(p.payment_value) AS revenue
FROM payments p  
LEFT JOIN orders o ON o.order_id = p.order_id
LEFT JOIN items i ON o.order_id = i.order_id
LEFT JOIN sellers s ON i.seller_id = s.seller_id
GROUP BY state ORDER BY revenue DESC LIMIT 5;

-- 2. Customers
-- How many unique customers made purchases in total?

SELECT COUNT(DISTINCT c.customer_unique_id) AS unique_customers 
FROM orders o  
LEFT JOIN customers c ON o.customer_id = c.customer_id
JOIN payments p ON o.order_id = p.order_id

-- How many customers placed more than one order?
WITH customers_orders AS (
	SELECT c.customer_unique_id AS unique_customer, COUNT (*) AS orders
	FROM orders o  
	JOIN customers c ON o.customer_id = c.customer_id
	GROUP BY customer_unique_id
	HAVING COUNT(o.order_id) > 1)
SELECT COUNT (*) FROM customers_orders

-- What is the average spending per customer?
WITH customers_spending AS (
	SELECT c.customer_unique_id AS customer, SUM(p.payment_value) AS spending
	FROM orders o  
	LEFT JOIN payments p  ON o.order_id = p.order_id
	JOIN customers c ON o.customer_id = c.customer_id
	GROUP BY customer)
SELECT ROUND(AVG(spending),2)
FROM customers_spending

-- 3. Products
-- Decision: prioritize catalog.
-- What are the best-selling products (by quantity)?
SELECT 
	product_category_name_english AS product, COUNT(i.product_id) AS items_sold
FROM items i
JOIN products p ON i.product_id = p.product_id
JOIN product_translation pt ON p.product_category_name = pt.product_category_name
GROUP BY  product ORDER BY items_sold DESC LIMIT 5;

-- Which categories generate the most revenue?
WITH order_revenue AS (
    SELECT order_id, SUM(payment_value) AS revenue
    FROM payments
    GROUP BY order_id
)
SELECT
    pt.product_category_name_english AS category,
    SUM(orv.revenue) AS revenue
FROM order_revenue orv
JOIN orders o ON orv.order_id = o.order_id
JOIN items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN product_translation pt ON p.product_category_name = pt.product_category_name
GROUP BY pt.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

-- 4. Logistics
-- What percentage of orders were delivered late?
SELECT
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date) AS late_orders,
    COUNT(*) AS delivered_orders,
	ROUND(100.0 *
        COUNT(*) FILTER (WHERE order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*),
        2) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- What is the average delivery time by state?
SELECT
	c.customer_state ,
	ROUND(AVG (order_delivered_customer_date::date - order_purchase_timestamp::date),2) AS average_delivery_time_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
GROUP BY c.customer_state ORDER BY average_delivery_time_days DESC;

