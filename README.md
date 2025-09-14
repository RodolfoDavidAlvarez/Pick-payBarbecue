# BBQ Pay & Pick Up System

A modern QR-code based ordering system for barbecue restaurants, enabling customers to order and pay online for quick pickup.

## Features

- 📱 Mobile-first QR code ordering
- 💳 Secure Stripe payment integration
- 📊 Real-time admin dashboard
- 🔔 Order status tracking
- 📦 Inventory management
- 📈 Analytics and reporting

## Tech Stack

- **Frontend**: React, TypeScript, Tailwind CSS
- **Backend**: Node.js, Express, TypeScript
- **Database**: Supabase (PostgreSQL)
- **Payments**: Stripe
- **Real-time**: Supabase Realtime

## Setup Instructions

### Prerequisites
- Node.js 16+
- npm or yarn
- Supabase account
- Stripe account

### Environment Variables

Create `.env` files in both client and server directories:

**Server (.env)**:
```
PORT=5000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret
```

**Client (.env)**:
```
REACT_APP_API_URL=http://localhost:5000
REACT_APP_SUPABASE_URL=your_supabase_url
REACT_APP_SUPABASE_ANON_KEY=your_supabase_anon_key
REACT_APP_STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
```

### Installation

1. Clone the repository
2. Install all dependencies:
   ```bash
   npm run install-all
   ```

3. Set up database (see database/schema.sql)

4. Start development servers:
   ```bash
   npm run dev
   ```
   
   This will start both the server (port 5000) and client (port 3000) concurrently.

## Usage

1. Generate QR code pointing to your deployed URL
2. Customers scan QR code to access menu
3. Select items and checkout with Stripe
4. Kitchen receives order in admin dashboard
5. Customer gets notified when order is ready

## Project Structure

```
.
├── client/                 # React frontend
│   ├── src/
│   │   ├── components/    # UI components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API services
│   │   └── types/         # TypeScript types
├── server/                 # Express backend
│   ├── src/
│   │   ├── routes/        # API routes
│   │   ├── controllers/   # Route handlers
│   │   ├── services/      # Business logic
│   │   └── types/         # TypeScript types
├── database/              # Database schema
└── package.json           # Root package with dev scripts
```

## License

MIT