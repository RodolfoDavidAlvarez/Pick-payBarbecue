# Admin Dashboard Setup Guide

## Database Setup

### 1. Create Tables (Run First!)

Run this script in your Supabase SQL editor to create all necessary tables:
```sql
-- Copy and run the contents of create-tables.sql
```

### 2. Authentication Setup

After creating tables, run the authentication setup:
```sql
-- Copy and run the contents of setup-admin-auth.sql
```

### 2. Create Admin User

In Supabase SQL editor, create your first admin user:

```sql
SELECT auth.admin_create_user(
  '{"email": "admin@yourdomain.com", "password": "your-secure-password", "email_confirm": true}'
);
```

### 3. Access Admin Dashboard

1. Navigate to `/admin` in your browser
2. You'll be redirected to `/admin/login`
3. Enter your admin credentials
4. Once logged in, you can access all admin features

## Admin Features

### Order Management
- View all orders in real-time
- Update order status (Pending → Confirmed → Preparing → Ready → Picked Up)
- Filter orders by status
- See order details and items

### Statistics Dashboard
- Today's revenue
- Total orders count
- Orders by status (Preparing, Ready, etc.)
- Real-time updates

### Product Management
- Toggle product availability
- Update inventory levels
- Manage product details

### Security Features
- Session-based authentication
- Protected routes
- Automatic logout on session expiry
- Row Level Security (RLS) policies

## Adding More Admins

To add additional admin users:

1. Go to Supabase Dashboard → Authentication → Users
2. Click "Invite User" or create via SQL:
```sql
SELECT auth.admin_create_user(
  '{"email": "newadmin@yourdomain.com", "password": "secure-password", "email_confirm": true}'
);
```

## Customization

### Extending Admin Roles

Currently, all authenticated users are treated as admins. To implement role-based access:

1. Add a `role` column to `admin_users` table
2. Update RLS policies to check specific roles
3. Modify `AuthContext` to check user roles from metadata

### Adding New Admin Features

The admin dashboard is built with React and can be extended:
- Add new routes in `App.tsx`
- Create new admin pages in `/client/src/pages/`
- Add API endpoints in `/server/src/routes/admin.ts`
- Protect new routes with `ProtectedRoute` component