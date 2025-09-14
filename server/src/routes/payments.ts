import express from 'express';
import { stripe, supabase } from '../index';

const router = express.Router();

// Create payment intent
router.post('/create-payment-intent', async (req, res) => {
  try {
    const { orderId, amount } = req.body;

    // Create payment intent
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
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(400).send(`Webhook Error: ${error}`);
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