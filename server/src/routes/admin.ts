import express from 'express';
import { supabase } from '../index';
import { authenticateAdmin, AuthRequest } from '../middleware/auth';

const router = express.Router();

// Apply authentication middleware to all admin routes
router.use(authenticateAdmin);

// Get all orders for admin dashboard
router.get('/orders', async (req, res) => {
  try {
    const { status, date } = req.query;
    
    let query = supabase
      .from('orders')
      .select(`
        *,
        order_items (*)
      `)
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    if (date) {
      const startDate = new Date(date as string);
      startDate.setHours(0, 0, 0, 0);
      const endDate = new Date(date as string);
      endDate.setHours(23, 59, 59, 999);
      
      query = query
        .gte('created_at', startDate.toISOString())
        .lte('created_at', endDate.toISOString());
    }

    const { data: orders, error } = await query;

    if (error) throw error;
    
    res.json(orders);
  } catch (error) {
    console.error('Error fetching admin orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Get dashboard statistics
router.get('/stats', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    // Get today's orders
    const { data: todaysOrders, error: ordersError } = await supabase
      .from('orders')
      .select('total, status')
      .gte('created_at', today.toISOString());

    if (ordersError) throw ordersError;

    // Calculate stats
    const stats = {
      todaysRevenue: todaysOrders
        .filter(order => order.status !== 'cancelled')
        .reduce((sum, order) => sum + Number(order.total), 0),
      todaysOrders: todaysOrders.length,
      pendingOrders: todaysOrders.filter(order => order.status === 'pending').length,
      preparingOrders: todaysOrders.filter(order => order.status === 'preparing').length,
      readyOrders: todaysOrders.filter(order => order.status === 'ready').length,
      completedOrders: todaysOrders.filter(order => order.status === 'picked_up').length,
    };

    res.json(stats);
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

// Update product availability
router.patch('/products/:id/availability', async (req, res) => {
  try {
    const { id } = req.params;
    const { is_available } = req.body;
    
    const { data: product, error } = await supabase
      .from('products')
      .update({ is_available })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    
    res.json(product);
  } catch (error) {
    console.error('Error updating product availability:', error);
    res.status(500).json({ error: 'Failed to update product availability' });
  }
});

// Update inventory
router.patch('/inventory/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const { quantity_available } = req.body;
    
    const { data: inventory, error } = await supabase
      .from('inventory')
      .update({ quantity_available })
      .eq('product_id', productId)
      .select()
      .single();

    if (error) throw error;
    
    res.json(inventory);
  } catch (error) {
    console.error('Error updating inventory:', error);
    res.status(500).json({ error: 'Failed to update inventory' });
  }
});

// Get low stock items
router.get('/inventory/low-stock', async (req, res) => {
  try {
    const { data: lowStock, error } = await supabase
      .from('inventory')
      .select(`
        *,
        products (name)
      `);

    if (error) throw error;
    
    res.json(lowStock);
  } catch (error) {
    console.error('Error fetching low stock items:', error);
    res.status(500).json({ error: 'Failed to fetch low stock items' });
  }
});

export default router;