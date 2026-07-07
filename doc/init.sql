DROP DATABASE IF EXISTS ecommerce_IronAxis;
CREATE DATABASE ecommerce_IronAxis;
USE ecommerce_IronAxis;

-- ========================================================
-- CREAZIONE TABELLE (DDL)
-- ========================================================

-- USERS
CREATE TABLE users (
    email VARCHAR(100) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(70) NOT NULL,
    password_salt VARCHAR(100) NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    role VARCHAR(20) DEFAULT 'user',
    date_of_birth DATE NOT NULL,
    is_deleted BOOLEAN DEFAULT false
);

-- ADDRESSES
CREATE TABLE addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    street_number int NOT NULL,
    city VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    province VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
);

-- PHONES
CREATE TABLE phones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    number VARCHAR(20) NOT NULL,
    type VARCHAR(20) DEFAULT 'PHONE' CHECK(type IN ('MOBILE', 'WORK', 'HOME')),
    FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
);

-- CATEGORIES
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)  NOT NULL,
    macro_category VARCHAR(50) NOT NULL,
    description TEXT
);

-- PRODUCTS
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_deleted BOOLEAN DEFAULT false,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- VARIANTS
CREATE TABLE variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_id INT NOT NULL,
    size VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    vat DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 0,
    image_data LONGBLOB,
    flavour VARCHAR(20) NOT NULL,
    nutr_tabl_data LONGBLOB,
    is_deleted BOOLEAN DEFAULT false,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- REVIEWS
CREATE TABLE reviews (
    user_email VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    score INT CHECK(score BETWEEN 1 AND 5),
    title VARCHAR(50) NOT NULL,
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(user_email, product_id),
    FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- CARTS
CREATE TABLE carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(100) UNIQUE NOT NULL,
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
);

-- CART_VARIANTS
CREATE TABLE cart_variants (
    cart_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT DEFAULT 1,
    PRIMARY KEY(cart_id, variant_id),
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES variants(id) ON DELETE CASCADE
);

-- ORDERS
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'PENDING' CHECK(status IN ('SHIPPED', 'PENDING', 'ON_DELIVERY', 'PROCESSING')),
    total_items INT NOT NULL,
    total_price DECIMAL(10,2),
    shipping_costs DECIMAL(10, 2),

    shipping_street VARCHAR(100) NOT NULL,
    shipping_street_number INT NOT NULL,
    shipping_city VARCHAR(50) NOT NULL,
    shipping_zip_code VARCHAR(10) NOT NULL,
    shipping_province VARCHAR(50) NOT NULL,
    shipping_country VARCHAR(50) NOT NULL,

    FOREIGN KEY (user_email) REFERENCES users(email),
);

-- ORDER_DETAILS
CREATE TABLE order_details (
    order_id INT NOT NULL,
    variant_id INT,
    quantity INT NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,
    vat DECIMAL(10,2) NOT NULL,

    product_name VARCHAR(100) NOT NULL,
    variant_sku VARCHAR(50) NOT NULL,
    variant_size VARCHAR(100) NOT NULL,
    variant_flavour VARCHAR(20) NOT NULL,

    PRIMARY KEY(order_id, variant_sku),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES variants(id) ON DELETE SET NULL
);

-- PAYMENTS
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    last_four_digits VARCHAR(4) NOT NULL,
    card_circuit VARCHAR(30) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE, 
    total_price DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'WAITING' CHECK(payment_status IN ('WAITING', 'COMPLETED', 'FAILED', 'REFUNDED')),
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- INVOICES
CREATE TABLE invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE NOT NULL,
    invoice_number VARCHAR(50) NOT NULL, 
    holder_first_name VARCHAR(100) NOT NULL, 
    holder_last_name VARCHAR(100) NOT NULL,
    taxable_total DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    billing_street VARCHAR(100) NOT NULL,
    billing_street_number INT NOT NULL,
    billing_city VARCHAR(50) NOT NULL,
    billing_zip_code VARCHAR(10) NOT NULL,
    billing_province VARCHAR(50) NOT NULL,
    billing_country VARCHAR(50) NOT NULL,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT
);