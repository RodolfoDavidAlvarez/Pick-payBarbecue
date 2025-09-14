#!/bin/bash

echo "🔥 BBQ Pay & Pick Up Setup Script 🔥"
echo "===================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js
if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Install server dependencies
echo ""
echo "📦 Installing server dependencies..."
cd server
npm install

# Install client dependencies
echo ""
echo "📦 Installing client dependencies..."
cd ../client
npm install

# Create environment files if they don't exist
echo ""
echo "🔧 Setting up environment files..."

if [ ! -f "../server/.env" ]; then
    cp ../server/.env.example ../server/.env
    echo "✅ Created server/.env - Please update with your credentials"
else
    echo "ℹ️  server/.env already exists"
fi

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ Created client/.env - Please update with your credentials"
else
    echo "ℹ️  client/.env already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update server/.env with your Supabase and Stripe credentials"
echo "2. Update client/.env with your Supabase and Stripe credentials"
echo "3. Run the database setup script in Supabase"
echo "4. Start the development servers:"
echo "   - Server: cd server && npm run dev"
echo "   - Client: cd client && npm start"
echo ""
echo "Happy coding! 🍖"