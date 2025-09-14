export interface Product {
  id: string;
  category_id: string;
  name: string;
  description: string;
  price: number;
  image_url?: string;
  is_available: boolean;
  preparation_time: number;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Order {
  id: string;
  order_number: string;
  customer_id?: string;
  customer_name: string;
  customer_phone: string;
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'cancelled';
  payment_status: 'pending' | 'completed' | 'failed' | 'refunded';
  stripe_payment_intent_id?: string;
  subtotal: number;
  tax: number;
  total: number;
  pickup_time?: string;
  notes?: string;
  is_arrived: boolean;
  arrived_at?: string;
  created_at: string;
  updated_at: string;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  product_name: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  special_instructions?: string;
  created_at: string;
}

export interface CartItem {
  product: Product;
  quantity: number;
  special_instructions?: string;
}

export interface CreateOrderRequest {
  customer_name: string;
  customer_phone: string;
  items: CartItem[];
  notes?: string;
  pickup_time?: string;
}

export interface Inventory {
  id: string;
  product_id: string;
  quantity_available: number;
  low_stock_threshold: number;
  created_at: string;
  updated_at: string;
}