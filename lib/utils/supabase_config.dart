// ─── Supabase Configuration (Listen Together) ─────────────────────────────────
//
// Supabase is used ONLY for the "Listen Together" real-time sync feature.
// No login, no user accounts — just ephemeral Realtime Broadcast channels.
//
// QUICK SETUP (~5 minutes, free):
//
//  1. Go to https://supabase.com → "Start your project" (free tier)
//  2. Create a new project
//  3. Go to: Project Settings → API
//  4. Copy:
//       • "Project URL"       → paste below as supabaseUrl
//       • "anon public" key   → paste below as supabaseAnonKey
//
// That's it — no tables, no auth, no extra config needed.
// The Listen Together feature uses ephemeral Broadcast channels only.
// ─────────────────────────────────────────────────────────────────────────────

const supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
