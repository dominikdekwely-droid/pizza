-- ==========================================
-- SCHEMA.SQL: Создание структуры базы данных Пиццерии
-- ==========================================

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_ingredients CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS supply_items CASCADE;
DROP TABLE IF EXISTS supplies CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS sizes CASCADE;
DROP TABLE IF EXISTS ingredients CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- 1. СПРАВОЧНИКИ
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    is_allergen BOOLEAN DEFAULT FALSE,
    unit VARCHAR(20) NOT NULL -- 'гр', 'мл', 'шт'
);

CREATE TABLE sizes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    diameter_cm INT,
    price_multiplier NUMERIC(3,2) DEFAULT 1.0
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    role VARCHAR(50) NOT NULL, -- manager, chef, courier, storekeeper
    hired_at DATE DEFAULT CURRENT_DATE
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. ПОСТАВЩИКИ И СКЛАД
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    address TEXT
);

CREATE TABLE supplies (
    id SERIAL PRIMARY KEY,
    supplier_id INT NOT NULL REFERENCES suppliers(id),
    employee_id INT NOT NULL REFERENCES employees(id), -- Кто принял товар
    supply_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_cost NUMERIC(12,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'received' -- pending, received, cancelled
);

CREATE TABLE supply_items (
    id SERIAL PRIMARY KEY,
    supply_id INT NOT NULL REFERENCES supplies(id) ON DELETE CASCADE,
    ingredient_id INT NOT NULL REFERENCES ingredients(id),
    quantity NUMERIC(10,3) NOT NULL,
    purchase_price NUMERIC(10,2) NOT NULL,
    UNIQUE(supply_id, ingredient_id) -- В одной поставке ингредиент встречается один раз
);

-- 3. ПРОДАЖИ И МЕНЮ
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES categories(id),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    base_price NUMERIC(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE product_ingredients (
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    ingredient_id INT NOT NULL REFERENCES ingredients(id),
    quantity NUMERIC(10,3) NOT NULL, -- Норма закладки
    PRIMARY KEY (product_id, ingredient_id)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    employee_id INT NOT NULL REFERENCES employees(id), -- Кто принял заказ
    status VARCHAR(50) NOT NULL DEFAULT 'new', -- new, cooking, delivering, done, cancelled
    total_amount NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_address TEXT
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    size_id INT NOT NULL REFERENCES sizes(id),
    quantity INT NOT NULL DEFAULT 1,
    price_at_moment NUMERIC(10,2) NOT NULL
);

-- Индексы для ускорения запросов (требование ТЗ)
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
