import express from 'express';
import { supabase } from '../index';

const router = express.Router();

// Simple admin authentication for development
const ADMIN_CREDENTIALS = {
  email: 'admin@bbqpay.com',
  password: 'admin123'
};

// Admin login
router.post('/admin/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // For development, use hardcoded credentials
    if (email === ADMIN_CREDENTIALS.email && password === ADMIN_CREDENTIALS.password) {
      // Create a mock session token
      const token = Buffer.from(`${email}:${Date.now()}`).toString('base64');
      
      res.json({
        success: true,
        token,
        user: {
          id: 'admin-001',
          email: ADMIN_CREDENTIALS.email,
          name: 'Admin User',
          role: 'admin'
        }
      });
    } else {
      res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Verify admin token
router.get('/admin/verify', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    
    // For development, just check if token exists
    if (token) {
      res.json({
        success: true,
        user: {
          id: 'admin-001',
          email: ADMIN_CREDENTIALS.email,
          name: 'Admin User',
          role: 'admin'
        }
      });
    } else {
      res.status(401).json({ error: 'Invalid token' });
    }
  } catch (error) {
    console.error('Verify error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

// Admin logout
router.post('/admin/logout', async (req, res) => {
  // For development, just return success
  res.json({ success: true });
});

export default router;