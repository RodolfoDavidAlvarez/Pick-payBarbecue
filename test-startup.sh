#!/bin/bash

echo "🧪 Testing BBQ Pay & Pick Up Startup..."
echo "======================================="

# Function to check if port is in use
check_port() {
    lsof -ti:$1 >/dev/null 2>&1
}

# Kill any existing processes
echo "🔄 Cleaning up existing processes..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5000 | xargs kill -9 2>/dev/null || true
sleep 2

# Test server startup
echo ""
echo "🚀 Testing server startup..."
cd server
npm run dev > /tmp/server.log 2>&1 &
SERVER_PID=$!
sleep 5

if check_port 5000; then
    echo "✅ Server started successfully on port 5000"
else
    echo "❌ Server failed to start"
    cat /tmp/server.log
fi

# Test client startup  
echo ""
echo "🚀 Testing client startup..."
cd ../client
BROWSER=none npm start > /tmp/client.log 2>&1 &
CLIENT_PID=$!
sleep 10

if check_port 3000; then
    echo "✅ Client started successfully on port 3000"
else
    echo "❌ Client failed to start"
    echo "Last 50 lines of log:"
    tail -50 /tmp/client.log
fi

# Cleanup
echo ""
echo "🧹 Cleaning up test processes..."
kill $SERVER_PID 2>/dev/null || true
kill $CLIENT_PID 2>/dev/null || true
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5000 | xargs kill -9 2>/dev/null || true

echo ""
echo "✨ Test complete!"