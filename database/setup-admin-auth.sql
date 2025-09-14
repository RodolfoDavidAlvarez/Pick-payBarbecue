-- Admin Authentication Setup for BBQ Pay & Pick Up

-- Create admin_users table
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(200) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);

-- Enable Row Level Security
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Create policy for admin users to read their own data
CREATE POLICY "Admin users can view their own data" ON admin_users
    FOR SELECT USING (auth.uid()::text = id::text);

-- Create function to hash passwords
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Using a simple hash for development. In production, use bcrypt
    RETURN encode(digest(password || 'bbq-salt-dev', 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql;

-- Create function to verify passwords
CREATE OR REPLACE FUNCTION verify_password(email_input TEXT, password_input TEXT)
RETURNS TABLE(user_id UUID, user_email TEXT, user_name TEXT, user_role TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT id, email, name, role
    FROM admin_users
    WHERE email = email_input 
    AND password_hash = hash_password(password_input)
    AND is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Insert default admin account for development
INSERT INTO admin_users (email, password_hash, name, role)
VALUES (
    'admin@bbqpay.com',
    hash_password('admin123'),
    'Admin User',
    'admin'
) ON CONFLICT (email) DO NOTHING;

-- Create a function to authenticate admin users
CREATE OR REPLACE FUNCTION authenticate_admin(email_input TEXT, password_input TEXT)
RETURNS JSON AS $$
DECLARE
    admin_record RECORD;
    result JSON;
BEGIN
    SELECT * INTO admin_record
    FROM admin_users
    WHERE email = email_input 
    AND password_hash = hash_password(password_input)
    AND is_active = true;
    
    IF admin_record.id IS NOT NULL THEN
        result := json_build_object(
            'success', true,
            'user', json_build_object(
                'id', admin_record.id,
                'email', admin_record.email,
                'name', admin_record.name,
                'role', admin_record.role
            )
        );
    ELSE
        result := json_build_object(
            'success', false,
            'error', 'Invalid credentials'
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION hash_password TO anon, authenticated;
GRANT EXECUTE ON FUNCTION verify_password TO anon, authenticated;
GRANT EXECUTE ON FUNCTION authenticate_admin TO anon, authenticated;