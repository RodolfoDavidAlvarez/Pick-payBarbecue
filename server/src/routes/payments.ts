import express from 'express';
import { stripe, supabase } from '../index';

const router = express.Router();

// Create payment intent
router.post('/create-payment-intent', async (req, res) => {
  try {
    const { orderId, amount } = req.body;

    // Check if using placeholder Stripe key (for development)
    if (process.env.STRIPE_SECRET_KEY === 'sk_test_placeholder') {
      console.log('Using mock payment intent for development');
      
      // Return mock client secret for development
      res.json({
        clientSecret: `pi_mock_${Date.now()}_secret_mock_development_key`
      });
      return;
    }

    // Create payment intent with real Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: 'usd',
      metadata: {
        order_id: orderId
      }
    });

    // Update order with payment intent ID
    const { error } = await supabase
      .from('orders')
      .update({ stripe_payment_intent_id: paymentIntent.id })
      .eq('id', orderId);

    if (error) throw error;

    res.json({
      clientSecret: paymentIntent.client_secret
    });
  } catch (error) {
    console.error('Error creating payment intent:', error);
    res.status(500).json({ error: 'Failed to create payment intent' });
  }
});

// Webhook to handle Stripe events
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;

  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    );

    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object as any;
        const orderId = paymentIntent.metadata.order_id;

        // Update order payment status
        await supabase
          .from('orders')
          .update({ 
            payment_status: 'completed',
            status: 'confirmed'
          })
          .eq('id', orderId);

        break;

      case 'payment_intent.payment_failed':
        const failedPaymentIntent = event.data.object as any;
        const failedOrderId = failedPaymentIntent.metadata.order_id;

        // Update order payment status
        await supabase
          .from('orders')
          .update({ payment_status: 'failed' })
          .eq('id', failedOrderId);

        break;
        
      case 'checkout.session.completed':
        const session = event.data.object as any;
        const sessionOrderId = session.metadata.orderId;
        
        // Update order payment status for Stripe Checkout
        await supabase
          .from('orders')
          .update({ 
            payment_status: 'completed',
            status: 'confirmed'
          })
          .eq('id', sessionOrderId);
          
        break;
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(400).send(`Webhook Error: ${error}`);
  }
});

// Create Stripe Checkout Session (supports Apple Pay automatically)
router.post('/create-checkout-session', async (req, res) => {
  try {
    const { orderId, items, customerEmail, customerPhone, customerName } = req.body;

    if (!orderId || !items || items.length === 0) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if using placeholder Stripe key (for development)
    if (process.env.STRIPE_SECRET_KEY === 'sk_test_placeholder') {
      console.log('Using mock checkout session for development');
      
      // Return mock checkout URL for development
      res.json({
        checkoutUrl: `http://localhost:3000/order-confirmation?session_id=mock_session_${Date.now()}&order_id=${orderId}`,
        sessionId: `cs_mock_${Date.now()}`
      });
      return;
    }

    // Create line items for Stripe Checkout
    const lineItems = items.map((item: any) => ({
      price_data: {
        currency: 'usd',
        product_data: {
          name: item.name,
          description: item.customizations ? `Customizations: ${item.customizations}` : undefined,
        },
        unit_amount: Math.round(item.price * 100), // Convert to cents
      },
      quantity: item.quantity,
    }));

    // Create Stripe Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: lineItems,
      mode: 'payment',
      success_url: `${process.env.CLIENT_URL || 'http://localhost:3000'}/order-confirmation?session_id={CHECKOUT_SESSION_ID}&order_id=${orderId}`,
      cancel_url: `${process.env.CLIENT_URL || 'http://localhost:3000'}/checkout?order_id=${orderId}`,
      customer_email: customerEmail,
      metadata: {
        orderId: orderId.toString(),
        customerPhone: customerPhone || '',
        customerName: customerName || '',
      },
      payment_intent_data: {
        metadata: {
          order_id: orderId.toString(),
        },
      },
    });

    // Store checkout session ID in order
    const { error: updateError } = await supabase
      .from('orders')
      .update({ 
        stripe_payment_intent_id: session.id,
        payment_status: 'pending'
      })
      .eq('id', orderId);

    if (updateError) {
      console.error('Error updating order:', updateError);
    }

    res.json({
      checkoutUrl: session.url,
      sessionId: session.id,
    });
  } catch (error) {
    console.error('Error creating checkout session:', error);
    res.status(500).json({ error: 'Failed to create checkout session' });
  }
});

// Confirm payment (for testing)
router.post('/confirm-payment', async (req, res) => {
  try {
    const { orderId } = req.body;

    // Update order status
    const { data: order, error } = await supabase
      .from('orders')
      .update({ 
        payment_status: 'completed',
        status: 'confirmed'
      })
      .eq('id', orderId)
      .select()
      .single();

    if (error) throw error;

    res.json(order);
  } catch (error) {
    console.error('Error confirming payment:', error);
    res.status(500).json({ error: 'Failed to confirm payment' });
  }
});

export default router;