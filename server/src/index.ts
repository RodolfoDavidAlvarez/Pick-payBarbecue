import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";
import Stripe from "stripe";

// Load environment variables
dotenv.config();

// Import routes
import ordersRouter from "./routes/orders";
import productsRouter from "./routes/products";
import paymentsRouter from "./routes/payments";
import adminRouter from "./routes/admin";

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5001;

// Initialize Supabase
export const supabase = createClient(
  process.env.SUPABASE_URL!, 
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

// Initialize Stripe
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2025-08-27.basil",
});

// Middleware
const allowedOrigins = [
  "http://localhost:3000",
  "https://bbq-pay-pickup.vercel.app",
  "https://bbq-pay-pickup-git-main.vercel.app",
];
if (process.env.VERCEL_URL) {
  allowedOrigins.push(`https://${process.env.VERCEL_URL}`);
}

app.use(
  cors({
    origin: allowedOrigins,
    credentials: true,
  })
);
app.use(express.json());

// Routes
app.use("/api/orders", ordersRouter);
app.use("/api/products", productsRouter);
app.use("/api/payments", paymentsRouter);
app.use("/api/admin", adminRouter);

// Health check endpoint
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: "Something went wrong!" });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
