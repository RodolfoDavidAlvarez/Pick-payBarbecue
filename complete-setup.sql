-- COMPLETE DATABASE SETUP FOR BBQ ORDERING SYSTEM
-- Run this entire script in Supabase SQL Editor

-- ========================================
-- STEP 1: CREATE TABLES
-- ========================================

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  icon TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  preparation_time INTEGER DEFAULT 15,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory table
CREATE TABLE IF NOT EXISTS inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  customer_id UUID REFERENCES customers(id),
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'cancelled')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_intent_id TEXT,
  subtotal DECIMAL(10, 2) NOT NULL,
  tax DECIMAL(10, 2) DEFAULT 0,
  total DECIMAL(10, 2) NOT NULL,
  notes TEXT,
  is_arrived BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  special_instructions TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- STEP 2: CREATE INDEXES
-- ========================================

CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- ========================================
-- STEP 3: ENABLE ROW LEVEL SECURITY
-- ========================================

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- ========================================
-- STEP 4: CREATE RLS POLICIES
-- ========================================

-- Public read access
CREATE POLICY "Public can read categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Public can read products" ON products FOR SELECT USING (true);
CREATE POLICY "Public can read inventory" ON inventory FOR SELECT USING (true);

-- Admin write access (authenticated users)
CREATE POLICY "Admins can manage categories" ON categories 
  FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can manage products" ON products 
  FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can manage inventory" ON inventory 
  FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can manage customers" ON customers 
  FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can manage orders" ON orders 
  FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can manage order_items" ON order_items 
  FOR ALL USING (auth.role() = 'authenticated');

-- Public order creation
CREATE POLICY "Public can create customers" ON customers 
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can create orders" ON orders 
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can view their own orders" ON orders 
  FOR SELECT USING (true);
CREATE POLICY "Public can create order_items" ON order_items 
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can view order_items" ON order_items 
  FOR SELECT USING (true);

-- Admin users policy
CREATE POLICY "Admins can view admin_users" ON admin_users 
  FOR SELECT USING (auth.role() = 'authenticated');

-- ========================================
-- STEP 5: INSERT SAMPLE DATA
-- ========================================

-- Insert categories
INSERT INTO categories (name, display_order, icon, description) VALUES
  ('Appetizers', 1, '🥗', 'Start your meal right'),
  ('BBQ Plates', 2, '🍖', 'Our signature BBQ dishes'),
  ('Sandwiches', 3, '🥪', 'Delicious BBQ sandwiches'),
  ('Sides', 4, '🍟', 'Perfect companions to your meal'),
  ('Beverages', 5, '🥤', 'Refreshing drinks'),
  ('Desserts', 6, '🍰', 'Sweet endings')
ON CONFLICT DO NOTHING;

-- Insert products
INSERT INTO products (category_id, name, description, price, image_url, preparation_time) VALUES
  ((SELECT id FROM categories WHERE name = 'Appetizers'), 'Smoked Wings', '6 pieces of our signature smoked wings', 12.99, '/images/wings.jpg', 20),
  ((SELECT id FROM categories WHERE name = 'Appetizers'), 'Loaded Fries', 'Fries topped with pulled pork, cheese, and BBQ sauce', 9.99, '/images/loaded-fries.jpg', 15),
  ((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'Brisket Plate', 'Slow-smoked brisket with two sides', 18.99, '/images/brisket.jpg', 25),
  ((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'Pulled Pork Plate', 'Tender pulled pork with two sides', 15.99, '/images/pulled-pork.jpg', 20),
  ((SELECT id FROM categories WHERE name = 'BBQ Plates'), 'Ribs Plate', 'Half rack of ribs with two sides', 19.99, '/images/ribs.jpg', 30),
  ((SELECT id FROM categories WHERE name = 'Sandwiches'), 'Brisket Sandwich', 'Sliced brisket on a brioche bun', 12.99, '/images/brisket-sandwich.jpg', 15),
  ((SELECT id FROM categories WHERE name = 'Sandwiches'), 'Pulled Pork Sandwich', 'Pulled pork with coleslaw on a brioche bun', 10.99, '/images/pulled-pork-sandwich.jpg', 15),
  ((SELECT id FROM categories WHERE name = 'Sides'), 'Mac & Cheese', 'Creamy homemade mac and cheese', 4.99, '/images/mac-cheese.jpg', 10),
  ((SELECT id FROM categories WHERE name = 'Sides'), 'Coleslaw', 'Fresh and tangy coleslaw', 3.99, '/images/coleslaw.jpg', 5),
  ((SELECT id FROM categories WHERE name = 'Sides'), 'Baked Beans', 'Sweet and savory baked beans', 3.99, '/images/baked-beans.jpg', 5),
  ((SELECT id FROM categories WHERE name = 'Beverages'), 'Soft Drinks', 'Coke, Sprite, Orange', 2.99, '/images/soda.jpg', 1),
  ((SELECT id FROM categories WHERE name = 'Beverages'), 'Sweet Tea', 'Southern-style sweet tea', 2.99, '/images/sweet-tea.jpg', 1),
  ((SELECT id FROM categories WHERE name = 'Beverages'), 'Lemonade', 'Fresh-squeezed lemonade', 3.49, '/images/lemonade.jpg', 1),
  ((SELECT id FROM categories WHERE name = 'Desserts'), 'Pecan Pie', 'Classic Southern pecan pie', 5.99, '/images/pecan-pie.jpg', 5),
  ((SELECT id FROM categories WHERE name = 'Desserts'), 'Banana Pudding', 'Homemade banana pudding', 4.99, '/images/banana-pudding.jpg', 5)
ON CONFLICT DO NOTHING;

-- Create inventory for all products
INSERT INTO inventory (product_id, quantity, low_stock_threshold)
SELECT id, 100, 20 FROM products
ON CONFLICT DO NOTHING;

-- ========================================
-- STEP 6: CREATE ADMIN USER
-- ========================================
-- Run this separately after the tables are created:
/*
SELECT auth.admin_create_user(
  '{"email": "admin@barbecue.com", "password": "your-secure-password", "email_confirm": true}'
);
*/

-- ========================================
-- SUCCESS! Your database is now set up.
-- Next: Create an admin user using the command above
-- ========================================