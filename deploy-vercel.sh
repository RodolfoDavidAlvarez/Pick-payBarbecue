#!/bin/bash

echo "🚀 Deploying BBQ Pay & Pick Up to Vercel..."
echo "============================================="

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI is not installed. Installing now..."
    npm install -g vercel
fi

# Check if user is logged in to Vercel
if ! vercel whoami &> /dev/null; then
    echo "🔐 Please log in to Vercel:"
    vercel login
fi

echo ""
echo "📦 Building client..."
cd client
npm run build
cd ..

echo ""
echo "🔧 Building server..."
cd server
npm run build
cd ..

echo ""
echo "🚀 Deploying to Vercel..."
vercel --prod

echo ""
echo "✅ Deployment complete!"
echo "🌐 Your app should be live at the URL shown above"
echo ""
echo "📝 Don't forget to:"
echo "   1. Set up environment variables in Vercel dashboard"
echo "   2. Update CORS origins if needed"
echo "   3. Test your deployment"
