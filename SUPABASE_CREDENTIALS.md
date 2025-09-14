# Supabase Project Credentials

**Project ID:** peibociexvwkgvlwuyeo  
**Dashboard URL:** https://supabase.com/dashboard/project/peibociexvwkgvlwuyeo

## Important Notes
- Store your API keys securely in .env files (never commit them)
- Get your project URL and keys from the Supabase dashboard:
  - Settings > API > Project URL
  - Settings > API > Project API keys (anon/public and service_role)

## Required Environment Variables

### Server (.env)
```
SUPABASE_URL=https://peibociexvwkgvlwuyeo.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Client (.env)
```
REACT_APP_SUPABASE_URL=https://peibociexvwkgvlwuyeo.supabase.co
REACT_APP_SUPABASE_ANON_KEY=your_anon_key_here
```

## Next Steps
1. Go to your Supabase dashboard
2. Navigate to Settings > API
3. Copy the Project URL and API keys
4. Create .env files in both client and server directories
5. Add the credentials to the .env files