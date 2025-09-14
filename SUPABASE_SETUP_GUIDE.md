# Supabase Setup Guide

## Project Information
- **Project ID**: peibociexvwkgvlwuyeo
- **Dashboard**: https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo

## Steps to Complete Setup

### 1. Get Your API Keys
1. Go to your [Supabase Dashboard](https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo)
2. Navigate to **Settings** > **API**
3. Copy these values:
   - **Project URL**: `https://peibociexvwkgvlwuyeo.supabase.co`
   - **anon/public key**: (starts with `eyJ...`)
   - **service_role key**: (starts with `eyJ...`) - Keep this secret!

### 2. Create Environment Files

#### Server .env file (`/server/.env`)
```bash
# Supabase Configuration
SUPABASE_URL=https://peibociexvwkgvlwuyeo.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# Server Configuration
PORT=3001
NODE_ENV=development

# Client URL
CLIENT_URL=http://localhost:3000
```

#### Client .env file (`/client/.env`)
```bash
# Supabase Configuration
REACT_APP_SUPABASE_URL=https://peibociexvwkgvlwuyeo.supabase.co
REACT_APP_SUPABASE_ANON_KEY=your_anon_key_here

# API Configuration
REACT_APP_API_URL=http://localhost:3001
```

### 3. Set Up Database Tables
1. Go to your [Supabase SQL Editor](https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo/sql)
2. Copy the contents of `/database/schema.sql`
3. Paste and run in the SQL Editor

### 4. Enable Row Level Security (RLS)
Run this in the SQL Editor after creating tables:
```sql
-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Create policies for read access (adjust as needed)
CREATE POLICY "Allow public read access" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON inventory FOR SELECT USING (true);
```

### 5. CLI Setup (Optional)
If you want to use Supabase CLI:
1. Get your access token from: https://supabase.com/dashboard/account/tokens
2. Run: `supabase login --token YOUR_ACCESS_TOKEN`
3. Link project: `supabase link --project-ref peibociexvwkgvlwuyeo`

## Testing the Connection
After setup, test by running:
- Server: `cd server && npm start`
- Client: `cd client && npm start`

The application should connect to your Supabase database.