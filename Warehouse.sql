/* CIS 344 Group Project - Jose Ramirez SQL Component

Building .sql backend to the warehouse */

/* creating the database where the warehouse schema (tables and joins) will be built */ 

CREATE DATABASE warehouse;
USE warehouse;

/* creating the tables to be used within the warehouse */

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(150),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
/* implementing foreign keys for joins to other tables in the database */
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    supplier_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    shipment_date DATE NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
/* using ENUM command to limit entries */
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    order_date DATE NOT NULL DEFAULT CURDATE(),
    total_amount DECIMAL(10, 2) DEFAULT 0,
    status ENUM('Pending', 'Shipped', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
/* using ENUM command to limit entries */
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(150),
    role ENUM('Admin', 'Manager', 'Employee') DEFAULT 'Employee',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* creating the triggers (notification settings) to give an alert when stock runs out and to update inventory count after an order is made */

CREATE TRIGGER prevent_negative_stock BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    SELECT stock_quantity INTO current_stock FROM products WHERE product_id = NEW.product_id;
    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Insufficient stock for product';
    END IF;
END


CREATE TRIGGER update_stock_after_order AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END

DELIMITER ;

