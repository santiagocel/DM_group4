-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

CREATE TABLE IF NOT EXISTS customer (
    customer_id INT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    membership ENUM('yes', 'no') NOT NULL
);

CREATE TABLE IF NOT EXISTS customer_address (
    customer_address_id INT PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    zip_code CHAR(10) NOT NULL,
    country CHAR(20) NOT NULL,
    state VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    street VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    order_status ENUM('Pending', 'Processing', 'Succeed', 'Cancelled') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);

CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    sub_quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT PRIMARY KEY NOT NULL,
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    transaction_time TIMESTAMP,
    payment_method ENUM('Credit card', 'Debit card', 'Paypal') NOT NULL,
    transaction_status ENUM ('Pending', 'Processing', 'Succeed', 'Cancelled') NOT NULL, 
    FOREIGN KEY (order_id) REFERENCES order (order_id), 
    FOREIGN KEY (customer_id) REFERENCES customer (customer_id) 
); 


CREATE TABLE delivery ( 
    delivery_id INT PRIMARY KEY NOT NULL, 
    transaction_id INT NOT NULL, 
    customer_address_id INT NOT NULL, 
    delivery_status ENUM ('Not_Deliveried', 'In_Delivery', 'Completed', 'Failed') NOT NULL, 
    delivery_start_date DATE, 
    delivery_end_date DATE, 
    FOREIGN KEY (transaction_id) REFERENCES transaction (transaction_id), 
    FOREIGN KEY (customer_address_id) REFERENCES customer_address (customer_address_id) 
); 

 

CREATE TABLE category ( 
    category_id INT PRIMARY KEY NOT NULL, 
    parent_category_id INT NOT NULL, 
    category_name VARCHAR (50) NOT NULL, 
    FOREIGN KEY (parent_category_id) REFERENCES category (category_id) 
); 

 

 

CREATE TABLE product ( 
    product_id INT PRIMARY KEY NOT NULL, 
    category_id INT NOT NULL, 
    product_name VARCHAR (100) NOT NULL, 
    product_price DECIMAL (10,2) NOT NULL, 
    discount_percentage FLOAT NOT NULL CHECK (discount_percentage >=0 AND discount_percentage <=1), 
    rate_value DECIMAL (2, 1) CHECK (rate_value >= 0 AND rate_value <= 5), 
    FOREIGN KEY (category_id) REFERENCES category (category _id) 
); 

 

CREATE TABLE supplier ( 
    supplier_id INT PRIMARY KEY NOT NULL,  
    supplier_phone VARCHAR (20) NOT NULL UNIQUE, 
    supplier_name VARCHAR (100) NOT NULL, 
    supplier_email VARCHAR (255) NOT NULL UNIQUE, 
    supplier_zip_code CHAR (10) NOT NULL,  
    supplier_country CHAR (20) NOT NULL,  
    supplier_state VARCHAR (50) NOT NULL,  
    supplier_city VARCHAR (50) NOT NULL,  
    supplier_street VARCHAR (255) NOT NULL 
) ;   

 

CREATE TABLE supply ( 
    supplier_id INT NOT NULL, 
    product_id INT NOT NULL, 
    stock INT NOT NULL, 
    PRIMARY KEY (supplier_id, product_id), 
    FOREIGN KEY (supplier_id) REFERENCES supplier (supplier_id), 
    FOREIGN KEY (product_id) REFERENCES product (product_id) 
) ;   

 

CREATE TABLE ads ( 
    ad_id INT PRIMARY KEY NOT NULL, 
    product_id INT NOT NULL, 
    ad_name VARCHAR (100) NOT NULL, 
    ad_status ENUM('active', 'ended'), 
    ad_start_date DATE NOT NULL, 
    ad_end_date DATE NOT NULL, 
    FOREIGN KEY (product_id) REFERENCES product (product_id) 
); 

 