import express from 'express';
import { supabase } from '../index';
import { CreateOrderRequest } from '../types';

const router = express.Router();

// Create a new order
router.post('/', async (req, res) => {
  try {
    const orderData: CreateOrderRequest = req.body;
    
    // Calculate totals
    const subtotal = orderData.items.reduce((sum, item) => 
      sum + (item.product.price * item.quantity), 0
    );
    const tax = subtotal * 0.0825; // 8.25% tax rate
    const total = subtotal + tax;

    // Generate order number
    const orderNumber = `BBQ${Date.now().toString().slice(-8)}`;

    // Create the order
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert({
        order_number: orderNumber,
        customer_name: orderData.customer_name,
        customer_phone: orderData.customer_phone,
        subtotal,
        tax,
        total,
        notes: orderData.notes,
        pickup_time: orderData.pickup_time,
        status: 'pending',
        payment_status: 'pending'
      })
      .select()
      .single();

    if (orderError) throw orderError;

    // Create order items
    const orderItems = orderData.items.map(item => ({
      order_id: order.id,
      product_id: item.product.id,
      product_name: item.product.name,
      quantity: item.quantity,
      unit_price: item.product.price,
      total_price: item.product.price * item.quantity,
      special_instructions: item.special_instructions
    }));

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems);

    if (itemsError) throw itemsError;

    // Update inventory
    for (const item of orderData.items) {
      const { error: inventoryError } = await supabase.rpc('decrement_inventory', {
        p_product_id: item.product.id,
        p_quantity: item.quantity
      });
      
      if (inventoryError) console.error('Inventory update error:', inventoryError);
    }

    res.json({ order, items: orderItems });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
});

// Get order by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', id)
      .single();

    if (orderError) throw orderError;
    
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const { data: items, error: itemsError } = await supabase
      .from('order_items')
      .select('*')
      .eq('order_id', id);

    if (itemsError) throw itemsError;

    res.json({ order, items });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ error: 'Failed to fetch order' });
  }
});

// Update order status
router.patch('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const { data: order, error } = await supabase
      .from('orders')
      .update({ status })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    
    res.json(order);
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

// Mark customer as arrived
router.post('/:id/arrived', async (req, res) => {
  try {
    const { id } = req.params;
    
    const { data: order, error } = await supabase
      .from('orders')
      .update({ 
        is_arrived: true,
        arrived_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    
    res.json(order);
  } catch (error) {
    console.error('Error marking customer arrival:', error);
    res.status(500).json({ error: 'Failed to mark customer arrival' });
  }
});

// Get order by phone number
router.get('/lookup/phone/:phone', async (req, res) => {
  try {
    const { phone } = req.params;
    
    const { data: orders, error } = await supabase
      .from('orders')
      .select('*')
      .eq('customer_phone', phone)
      .in('status', ['confirmed', 'preparing', 'ready'])
      .order('created_at', { ascending: false });

    if (error) throw error;
    
    res.json(orders);
  } catch (error) {
    console.error('Error looking up orders:', error);
    res.status(500).json({ error: 'Failed to lookup orders' });
  }
});

export default router;