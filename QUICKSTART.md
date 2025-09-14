# BBQ Pay & Pick Up - Quick Start Guide

## 🚀 Getting Started

### 1. Prerequisites
- Node.js 16+ installed
- Supabase account (free tier works)
- Stripe account (test mode is fine)

### 2. Clone and Setup
```bash
# Clone the repo (or use existing files)
cd bbq-pay-pickup

# Run setup script
./setup.sh
```

### 3. Configure Supabase

1. Create a new Supabase project at https://supabase.com
2. Go to SQL Editor and run the scripts in this order:
   - `database/schema.sql`
   - `database/functions.sql`
3. Get your credentials from Settings > API:
   - Project URL
   - Anon public key

### 4. Configure Stripe

1. Log in to Stripe Dashboard (https://stripe.com)
2. Toggle to Test Mode
3. Get your test API keys:
   - Publishable key
   - Secret key

### 5. Update Environment Variables

**server/.env**
```
PORT=5000
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=optional_for_local_testing
```

**client/.env**
```
REACT_APP_API_URL=http://localhost:5000
REACT_APP_SUPABASE_URL=your_project_url
REACT_APP_SUPABASE_ANON_KEY=your_anon_key
REACT_APP_STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
```

### 6. Start Development Servers

In separate terminals:

```bash
# Terminal 1 - Backend
cd server
npm run dev

# Terminal 2 - Frontend
cd client
npm start
```

### 7. Access the Application

- Customer QR Landing: http://localhost:3000/qr
- Admin Dashboard: http://localhost:3000/admin
- Customer Arrival: http://localhost:3000/arrival

## 📱 Testing the Flow

### Customer Flow:
1. Visit http://localhost:3000/qr (simulates QR code scan)
2. Browse menu and add items to cart
3. Proceed to checkout
4. Enter name and phone number
5. Complete order (payment is simulated in test mode)
6. See order confirmation
7. When ready for pickup, click "I'm Here!"

### Admin Flow:
1. Visit http://localhost:3000/admin
2. View incoming orders in real-time
3. Update order status as you prepare them
4. See when customers arrive
5. Mark orders as picked up

## 🎯 Test Data

The database comes pre-populated with:
- 6 menu categories
- 22 products with test prices ($0.19 - $2.49)
- 100 units of each item in inventory

## 🔧 Troubleshooting

### Common Issues:

1. **"Cannot connect to database"**
   - Check Supabase credentials in .env files
   - Ensure database schema is created

2. **"Stripe not working"**
   - Verify Stripe keys are in test mode
   - Check both publishable and secret keys

3. **"Orders not updating in real-time"**
   - Check Supabase Realtime is enabled
   - Verify WebSocket connections aren't blocked

## 📲 Generate QR Code

To generate a QR code for your restaurant:

1. Deploy your app to a public URL
2. Use any QR code generator
3. Point it to: `https://your-domain.com/qr`
4. Print and display at tables/counter

## 🚀 Next Steps

- Customize restaurant name and branding
- Update menu items and prices
- Add your own product images
- Configure SMS notifications
- Set up production Stripe account
- Deploy to production hosting