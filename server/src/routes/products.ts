import express from 'express';
import { supabase } from '../index';
import { Product, Category } from '../types';

const router = express.Router();

// Get all categories with their products
router.get('/menu', async (req, res) => {
  try {
    // Get all active categories
    const { data: categories, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('is_active', true)
      .order('display_order');

    if (categoriesError) throw categoriesError;

    // Get all available products
    const { data: products, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('is_available', true);

    if (productsError) throw productsError;

    // Group products by category
    const menu = categories.map(category => ({
      ...category,
      products: products.filter(product => product.category_id === category.id)
    }));

    res.json(menu);
  } catch (error) {
    console.error('Error fetching menu:', error);
    res.status(500).json({ error: 'Failed to fetch menu' });
  }
});

// Get single product
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const { data: product, error } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json(product);
  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

// Check product availability
router.post('/check-availability', async (req, res) => {
  try {
    const { productIds } = req.body;
    
    const { data: inventory, error } = await supabase
      .from('inventory')
      .select('product_id, quantity_available')
      .in('product_id', productIds);

    if (error) throw error;

    const availability = inventory.reduce((acc, item) => {
      acc[item.product_id] = item.quantity_available > 0;
      return acc;
    }, {} as Record<string, boolean>);

    res.json(availability);
  } catch (error) {
    console.error('Error checking availability:', error);
    res.status(500).json({ error: 'Failed to check availability' });
  }
});

export default router;