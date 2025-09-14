#!/bin/bash

echo "🍖 BBQ Pay & Pick Up - Supabase Setup Script"
echo "==========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env files exist
if [ ! -f "server/.env" ]; then
    echo -e "${YELLOW}Creating server/.env file...${NC}"
    cat > server/.env << EOF
# Supabase Configuration
SUPABASE_URL=https://peibociexvwkgvlwuyeo.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY_HERE

# Server Configuration
PORT=3001
NODE_ENV=development

# Client URL
CLIENT_URL=http://localhost:3000
EOF
    echo -e "${GREEN}✓ Created server/.env${NC}"
else
    echo -e "${YELLOW}server/.env already exists${NC}"
fi

if [ ! -f "client/.env" ]; then
    echo -e "${YELLOW}Creating client/.env file...${NC}"
    cat > client/.env << EOF
# Supabase Configuration
REACT_APP_SUPABASE_URL=https://peibociexvwkgvlwuyeo.supabase.co
REACT_APP_SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE

# API Configuration
REACT_APP_API_URL=http://localhost:3001
EOF
    echo -e "${GREEN}✓ Created client/.env${NC}"
else
    echo -e "${YELLOW}client/.env already exists${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1. Get your Supabase API keys:"
echo "   - Go to: https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo/settings/api"
echo "   - Copy the 'anon' key and 'service_role' key"
echo ""
echo "2. Update the .env files:"
echo "   - Edit server/.env and client/.env"
echo "   - Replace YOUR_ANON_KEY_HERE with your actual anon key"
echo "   - Replace YOUR_SERVICE_ROLE_KEY_HERE with your actual service role key"
echo ""
echo "3. Set up the database:"
echo "   - Go to: https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo/sql"
echo "   - Copy the contents of database/complete-setup.sql"
echo "   - Paste and run in the SQL Editor"
echo ""
echo "4. Start the application:"
echo "   - Terminal 1: cd server && npm start"
echo "   - Terminal 2: cd client && npm start"
echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"