# Vercel Deployment Guide

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com) (free tier works)
2. **Vercel CLI**: Install globally with `npm install -g vercel`
3. **Environment Variables**: Your production credentials

## Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

## Step 2: Login to Vercel

```bash
vercel login
```

## Step 3: Set Up Environment Variables

You'll need to configure these environment variables in Vercel:

### Server Environment Variables (in Vercel Dashboard):

- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon key
- `STRIPE_SECRET_KEY` - Your Stripe secret key
- `STRIPE_WEBHOOK_SECRET` - Your Stripe webhook secret (optional)
- `NODE_ENV` - Set to "production"

### Client Environment Variables (in Vercel Dashboard):

- `REACT_APP_API_URL` - Your Vercel API URL (will be provided after deployment)
- `REACT_APP_SUPABASE_URL` - Your Supabase project URL
- `REACT_APP_SUPABASE_ANON_KEY` - Your Supabase anon key
- `REACT_APP_STRIPE_PUBLISHABLE_KEY` - Your Stripe publishable key

## Step 4: Deploy

### Option A: Use the deployment script

```bash
./deploy-vercel.sh
```

### Option B: Manual deployment

```bash
# Deploy the entire project
vercel --prod
```

## Step 5: Configure Environment Variables in Vercel

1. Go to your Vercel dashboard
2. Select your project
3. Go to Settings > Environment Variables
4. Add all the environment variables listed above
5. Redeploy your project

## Step 6: Update API URL

After deployment, you'll get a URL like `https://your-project.vercel.app`. Update your client environment variable:

- `REACT_APP_API_URL` = `https://your-project.vercel.app/api`

## Step 7: Test Your Deployment

1. Visit your deployed URL
2. Test the QR code flow: `https://your-project.vercel.app/qr`
3. Test the admin dashboard: `https://your-project.vercel.app/admin`
4. Test the customer arrival: `https://your-project.vercel.app/arrival`

## Troubleshooting

### Common Issues:

1. **CORS Errors**: Make sure your Vercel URL is added to the CORS origins in `server/src/index.ts`

2. **Environment Variables Not Working**:

   - Check that variables are set in Vercel dashboard
   - Redeploy after adding variables
   - Make sure variable names match exactly

3. **Build Failures**:

   - Check that all dependencies are installed
   - Verify TypeScript compilation
   - Check build logs in Vercel dashboard

4. **API Routes Not Working**:
   - Verify the `vercel.json` configuration
   - Check that routes are properly defined
   - Test API endpoints directly

## Project Structure for Vercel

```
/
├── vercel.json          # Main Vercel config
├── client/              # React frontend
│   ├── vercel.json     # Client-specific config
│   └── build/          # Built files (generated)
├── server/              # Express backend
│   ├── vercel.json     # Server-specific config
│   └── dist/           # Built files (generated)
└── deploy-vercel.sh    # Deployment script
```

## Next Steps After Deployment

1. **Generate QR Code**: Use any QR code generator pointing to `https://your-domain.com/qr`
2. **Set Up Custom Domain**: Add your own domain in Vercel dashboard
3. **Configure Stripe Webhooks**: Set up webhooks for production
4. **Monitor Performance**: Use Vercel Analytics
5. **Set Up CI/CD**: Connect your GitHub repo for automatic deployments

## Support

If you encounter issues:

1. Check Vercel deployment logs
2. Verify environment variables
3. Test locally first
4. Check browser console for errors
