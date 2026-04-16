// ─── Supabase Configuration ───────────────────────────────────────────────────
//
// QUICK SETUP (no server, no SHA-1 fingerprint, ~5 minutes):
//
//  1. Go to https://supabase.com  → click "Start your project" (free tier)
//  2. Create a new project (choose a region close to your users)
//  3. Once the project is ready, go to:
//       Project Settings → API
//  4. Copy:
//       • "Project URL"       → paste below as supabaseUrl
//       • "anon public" key   → paste below as supabaseAnonKey
//  5. (Optional but recommended) Disable email confirmation:
//       Authentication → Providers → Email → disable "Confirm email"
//       This lets users start using the app immediately after sign-up.
//
// That's it! No Firebase, no SHA-1, no google-services.json needed.
// ─────────────────────────────────────────────────────────────────────────────

const supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
