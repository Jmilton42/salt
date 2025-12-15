-- PostgreSQL Database Setup for Ghost Energy Stock

-- Create database
CREATE DATABASE energy_stock;

-- Connect to the database
\c energy_stock;

-- Set client encoding to UTF8 to handle special characters
SET client_encoding = 'UTF8';

-- Drop tables if they exist to allow re-running
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- Create products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO products (name, stock, image_url) VALUES
('SOUR STRIPS® "RAINBOW"', 30, 'https://drinkghost.com/cdn/shop/files/EnergySourStripsFront_1242x1674.webp?v=1724186891'),
('WELCH''S® "GRAPE"', 9, 'https://i5.walmartimages.com/seo/GHOST-Welch-s-Grape-16oz-Single_1e36fdbd-fcfa-42e6-9ee2-4ce42040aa79.bbe14372c8583699233fa83dc824cf24.png'),
('''MERICA POP', 21, 'https://drinkghost.com/cdn/shop/files/MericaPopFront_1242x1674.webp?v=1744831720'),
('OG', 30, 'https://drinkghost.com/cdn/shop/files/OGFront_b5090f47-67f3-4a61-9c9d-43229be0709c_1242x1674.webp?v=1756221881'),
('PEACHES', 30, 'https://drinkghost.com/cdn/shop/files/PeachesFront_1242x1674.webp?v=1744833336'),
('RASPBERRY CREAM', 18, 'https://drinkghost.com/cdn/shop/files/RaspberryCreamFront_700x.webp?v=1753198311'),
('STRAWBANGO™', 20, 'https://drinkghost.com/cdn/shop/files/StrawbangoFront_700x.webp?v=1744833958');

-- Create a users table for additional SQLi practice
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample users (passwords are plaintext for demo purposes)
INSERT INTO users (username, password, email, role) VALUES
('admin', 'admin123', 'admin@ghostenergy.com', 'admin'),
('manager', 'manager123', 'manager@ghostenergy.com', 'manager'),
('user', 'user123', 'user@ghostenergy.com', 'user');

-- Grant permissions (adjust as needed)
GRANT ALL PRIVILEGES ON DATABASE energy_stock TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

