# Admin Dashboard Credentials

## Development Admin Account

The admin dashboard is pre-configured with the following credentials for development:

**Email:** `admin@bbqpay.com`  
**Password:** `admin123`

## Accessing the Admin Dashboard

1. Go to: http://localhost:3000/admin/login
2. Use the credentials above (they're pre-filled)
3. Click "Sign In"

## Admin Features

Once logged in, you can:
- View all orders
- Update order status
- View customer information
- Track daily revenue
- Manage inventory (coming soon)
- View analytics (coming soon)

## Security Notes

⚠️ **For Development Only**: These credentials are hardcoded for development convenience. In production:
- Use Supabase Auth with proper user management
- Enable Row Level Security (RLS)
- Use environment-specific credentials
- Implement proper role-based access control

## API Authentication

The admin authentication uses a simple token-based system:
- Login endpoint: `POST /api/auth/admin/login`
- Returns a token that should be included in subsequent requests
- Token is stored in localStorage for persistence