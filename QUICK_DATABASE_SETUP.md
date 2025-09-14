# Quick Database Setup

Your Supabase credentials are now configured! Here's how to set up the database:

## Option 1: Quick Copy & Paste (Recommended)

1. **Open Supabase SQL Editor**:
   https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo/sql/new

2. **Copy the SQL**:
   Open `database/complete-setup.sql` in your editor

3. **Paste and Run**:
   - Paste the entire SQL content into the SQL Editor
   - Click "Run" (or press Cmd/Ctrl + Enter)

## Option 2: Using Supabase CLI

If you have your database password:
```bash
supabase db push --db-url "postgresql://postgres:YOUR_DB_PASSWORD@db.peibociexvwkgvlwuyeo.supabase.co:5432/postgres" < database/complete-setup.sql
```

## Verify Setup

After running the SQL, verify:
1. **Tables Created**: categories, products, inventory, customers, orders, order_items
2. **Sample Data**: Check that products are loaded with test prices
3. **Functions**: decrement_inventory, increment_inventory, get_available_products

## Test the Application

```bash
# Terminal 1 - Start the server
cd server && npm start

# Terminal 2 - Start the client
cd client && npm start
```

Visit http://localhost:3000/qr to see your menu!

## Troubleshooting

If you see any errors:
- "relation already exists" - Tables are already created, this is fine
- "duplicate key" - Sample data already exists, this is fine
- Connection errors - Check your .env files have the correct keys