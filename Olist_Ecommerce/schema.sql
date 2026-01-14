-- Creating tables and loading data from local CSV files.
-- Paths are local and should be adjusted per environment.
  
-- 1. Customers
CREATE TABLE customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

COPY customers
FROM '/Library/PostgreSQL/13/data/imports/olist_customers_dataset.csv'
CSV HEADER;

-- 2. Geolocation
CREATE TABLE geolocation (
	geolocation_zip_code_prefix TEXT,
	geolocation_lat TEXT,
	geolocation_lng TEXT,
	geolocation_city TEXT,
	geolocation_state TEXT
);

COPY geolocation
FROM '/Library/PostgreSQL/13/data/imports/olist_geolocation_dataset.csv'
CSV HEADER;

-- 3. Items

CREATE TABLE items (
	order_id TEXT,
	order_item_id TEXT,
	product_id TEXT,
	seller_id TEXT,
	shipping_limit_date DATE,
	price DECIMAL,
	freight_value DECIMAL
);

COPY items
FROM '/Library/PostgreSQL/13/data/imports/olist_order_items_dataset.csv'
CSV HEADER;

-- 4.  Payments
CREATE TABLE payments (
	order_id TEXT,
	payment_sequential INTEGER,
	payment_type TEXT,
	payment_installments INTEGER,
	payment_value DECIMAL
);

COPY payments
FROM '/Library/PostgreSQL/13/data/imports/olist_order_payments_dataset.csv'
CSV HEADER;

-- 5. Reviews
CREATE TABLE reviews (
	review_id TEXT,
	order_id TEXT,
	review_score TEXT,
	review_comment_title TEXT,
	review_comment_message TEXT,
	review_creation_date TEXT,
	review_answer_timestamp TEXT
);

COPY reviews
FROM '/Library/PostgreSQL/13/data/imports/olist_order_reviews_dataset.csv'
CSV HEADER;

ALTER TABLE reviews
  ALTER COLUMN review_creation_date TYPE DATE
  USING to_timestamp(review_creation_date, 'DD/MM/YY HH24:MI')::date,

  ALTER COLUMN review_answer_timestamp TYPE TIMESTAMP
  USING to_timestamp(review_answer_timestamp, 'DD/MM/YY HH24:MI');


-- 6. Orders
CREATE TABLE orders(
	order_id TEXT,
	customer_id TEXT,
	order_status TEXT,
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date DATE,
	order_delivered_customer_date DATE,
	order_estimated_delivery_date DATE
);

COPY orders
FROM '/Library/PostgreSQL/13/data/imports/olist_orders_dataset.csv'
CSV HEADER;

SELECT * FROM orders LIMIT 5;

--- 7. Products
CREATE TABLE products (
	product_id TEXT,
	product_category_name TEXT,
	product_name_lenght INTEGER,
	product_description_lenght TEXT,
	product_photos_qty INTEGER,
	product_weight_g DECIMAL,
	product_length_cm INTEGER,
	product_height_cm INTEGER,
	product_width_cm INTEGER)
;

COPY products
FROM '/Library/PostgreSQL/13/data/imports/olist_products_dataset.csv'
CSV HEADER;

-- 8. Sellers
CREATE TABLE sellers (
	seller_id  TEXT,
	seller_zip_code_prefix INTEGER,
	seller_city TEXT,
	seller_state TEXT)
;

COPY sellers
FROM '/Library/PostgreSQL/13/data/imports/olist_sellers_dataset.csv'
CSV HEADER;

--- 9. Product category name translation
CREATE TABLE product_translation(
	product_category_name TEXT,
	product_category_name_english TEXT
);

COPY product_translation
FROM '/Library/PostgreSQL/13/data/imports/product_category_name_translation.csv'
CSV HEADER;
