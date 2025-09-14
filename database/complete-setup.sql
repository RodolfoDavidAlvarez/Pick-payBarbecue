-- BBQ Pay & Pick Up Database Complete Setup
-- Run this file in Supabase SQL Editor to set up everything

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    preparation_time INT DEFAULT 15, -- in minutes
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory table
CREATE TABLE IF NOT EXISTS inventory (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity_available INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id),
    customer_name VARCHAR(200) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, preparing, ready, picked_up, cancelled
    payment_status VARCHAR(50) DEFAULT 'pending', -- pending, completed, failed, refunded
    stripe_payment_intent_id VARCHAR(255),
    subtotal DECIMAL(10, 2) NOT NULL,
    tax DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    pickup_time TIMESTAMPTZ,
    notes TEXT,
    is_arrived BOOLEAN DEFAULT false,
    arrived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(200) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON orders(customer_phone);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'BBQ' || TO_CHAR(NOW(), 'YYMMDD') || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to decrement inventory when order is placed
CREATE OR REPLACE FUNCTION decrement_inventory(p_product_id UUID, p_quantity INT)
RETURNS VOID AS $$
BEGIN
    UPDATE inventory
    SET quantity_available = GREATEST(quantity_available - p_quantity, 0)
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment inventory when order is cancelled
CREATE OR REPLACE FUNCTION increment_inventory(p_product_id UUID, p_quantity INT)
RETURNS VOID AS $$
BEGIN
    UPDATE inventory
    SET quantity_available = quantity_available + p_quantity
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get available products with inventory
CREATE OR REPLACE FUNCTION get_available_products()
RETURNS TABLE (
    id UUID,
    category_id UUID,
    name VARCHAR,
    description TEXT,
    price DECIMAL,
    image_url TEXT,
    is_available BOOLEAN,
    preparation_time INT,
    quantity_available INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.category_id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        p.is_available,
        p.preparation_time,
        COALESCE(i.quantity_available, 0) as quantity_available
    FROM products p
    LEFT JOIN inventory i ON p.id = i.product_id
    WHERE p.is_available = true
    AND (i.quantity_available IS NULL OR i.quantity_available > 0);
END;
$$ LANGUAGE plpgsql;

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON inventory FOR SELECT USING (true);

-- Create policies for orders (customers can see their own orders)
CREATE POLICY "Customers can view their orders" ON orders 
    FOR SELECT USING (true);

CREATE POLICY "Customers can create orders" ON orders 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Customers can update their orders" ON orders 
    FOR UPDATE USING (true);

-- Create policies for order items
CREATE POLICY "View order items" ON order_items 
    FOR SELECT USING (true);

CREATE POLICY "Create order items" ON order_items 
    FOR INSERT WITH CHECK (true);

-- Sample data for categories
INSERT INTO categories (name, display_order, is_active) VALUES
('Appetizers', 1, true),
('BBQ Plates', 2, true),
('Sandwiches', 3, true),
('Sides', 4, true),
('Drinks', 5, true),
('Desserts', 6, true)
ON CONFLICT DO NOTHING;

-- Sample data for products (with low test prices)
INSERT INTO products (category_id, name, description, price, preparation_time) VALUES
-- Appetizers
((SELECT id FROM categories WHERE name = 'Appetizers'), 'Smoked Wings', '6 jumbo wings with your choice of BBQ or buffalo sauce', 0.99, 15),
((SELECT id FROM categories WHERE name = 'Appetizers'), 'Loaded Nachos', 'Tortilla chips topped with pulled pork, cheese, jalapeños, and BBQ sauce', 0.49, 10),
((SELECT id FROM categories WHERE name = 'Appetizers'), 'Fried Pickles', 'Crispy breaded pickle chips with ranch dipping sauce', 0.39, 8),

-- BBQ Plates
((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'Brisket Plate', 'Half pound of slow-smoked brisket with two sides and cornbread', 1.99, 20),
((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'Pulled Pork Plate', 'Tender pulled pork with two sides and cornbread', 1.49, 15),
((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'BBQ Combo Plate', 'Brisket, pulled pork, and sausage with two sides', 2.49, 20),
((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'Ribs Plate', 'Half rack of baby back ribs with two sides', 1.99, 25),

-- Sandwiches
((SELECT id FROM categories WHERE name = 'Sandwiches'), 'Brisket Sandwich', 'Sliced brisket on a brioche bun with pickles and onions', 0.99, 10),
((SELECT id FROM categories WHERE name = 'Sandwiches'), 'Pulled Pork Sandwich', 'Pulled pork with coleslaw on a brioche bun', 0.79, 10),
((SELECT id FROM categories WHERE name = 'Sandwiches'), 'BBQ Burger', 'Angus beef burger with BBQ sauce, bacon, and onion rings', 0.89, 15),

-- Sides
((SELECT id FROM categories WHERE name = 'Sides'), 'Mac & Cheese', 'Creamy three-cheese mac and cheese', 0.29, 5),
((SELECT id FROM categories WHERE name = 'Sides'), 'Coleslaw', 'Fresh and tangy coleslaw', 0.19, 5),
((SELECT id FROM categories WHERE name = 'Sides'), 'BBQ Beans', 'Slow-cooked beans with bacon', 0.19, 5),
((SELECT id FROM categories WHERE name = 'Sides'), 'French Fries', 'Crispy golden fries', 0.29, 8),
((SELECT id FROM categories WHERE name = 'Sides'), 'Cornbread', 'Sweet honey cornbread', 0.19, 5),

-- Drinks
((SELECT id FROM categories WHERE name = 'Drinks'), 'Soft Drinks', 'Coke, Sprite, Dr Pepper, Orange', 0.19, 1),
((SELECT id FROM categories WHERE name = 'Drinks'), 'Sweet Tea', 'House-made sweet tea', 0.19, 1),
((SELECT id FROM categories WHERE name = 'Drinks'), 'Lemonade', 'Fresh squeezed lemonade', 0.29, 1),
((SELECT id FROM categories WHERE name = 'Drinks'), 'Beer', 'Selection of local craft beers', 0.49, 1),

-- Desserts
((SELECT id FROM categories WHERE name = 'Desserts'), 'Pecan Pie', 'Classic Southern pecan pie', 0.39, 2),
((SELECT id FROM categories WHERE name = 'Desserts'), 'Banana Pudding', 'Homemade banana pudding with vanilla wafers', 0.29, 2),
((SELECT id FROM categories WHERE name = 'Desserts'), 'Brownies', 'Fudgy chocolate brownies', 0.19, 2)
ON CONFLICT DO NOTHING;

-- Initialize inventory for all products
INSERT INTO inventory (product_id, quantity_available, low_stock_threshold)
SELECT id, 100, 10 FROM products
ON CONFLICT DO NOTHING;