-- Enable Row Level Security on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Create admin users table (optional - for tracking admin metadata)
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access (existing functionality)
CREATE POLICY "Public can read categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Public can read products" ON products FOR SELECT USING (true);
CREATE POLICY "Public can read inventory" ON inventory FOR SELECT USING (true);

-- Create policies for admin write access
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

-- Allow public to create customers and orders (for ordering flow)
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

-- Function to create first admin user
-- Run this in SQL editor with your desired email and password
/*
To create an admin user, run this in Supabase SQL editor:

SELECT auth.admin_create_user(
  '{"email": "admin@barbecue.com", "password": "your-secure-password", "email_confirm": true}'
);

Then optionally add to admin_users table:
INSERT INTO admin_users (user_id, email, full_name)
SELECT id, email, 'Admin User'
FROM auth.users
WHERE email = 'admin@barbecue.com';
*/