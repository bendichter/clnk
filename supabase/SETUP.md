# Clnk Supabase Setup

## 1. Create Project

1. Go to [supabase.com](https://supabase.com) → New Project
2. Name: `clnk` (or whatever you like)
3. Database password: **Save this somewhere safe!**
4. Region: `us-east-1` (closest to Alexandria)
5. Wait for project to spin up (~2 min)

## 2. Run Schema

1. Go to **SQL Editor** in the sidebar
2. Click **New Query**
3. Paste the contents of `schema.sql`
4. Click **Run** (or Cmd+Enter)
5. Should see "Success. No rows returned" for each statement

## 3. Enable PostGIS (if not already)

In SQL Editor, run:
```sql
create extension if not exists "postgis";
```

## 4. Create Storage Buckets

1. Go to **Storage** in the sidebar
2. Click **New Bucket**
3. Create two buckets:
   - `avatars` (public)
   - `rating-photos` (public)

## 5. Get Your Keys

Go to **Settings → API** and grab:

- **Project URL**: `https://xxxxx.supabase.co`
- **anon (public) key**: `eyJhbGciOi...` (safe for client)
- **service_role key**: `eyJhbGciOi...` (keep secret, server only)

Save these to `secrets/.env`:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_KEY=eyJhbGciOi...
```

## 6. Enable Auth Providers

Go to **Authentication → Providers**:

- [x] Email (enabled by default)
- [ ] Apple (add for iOS App Store)
- [ ] Google (optional)

For Apple Sign-In, you'll need:
- Apple Developer account
- Service ID + private key

We can set this up later.

## 7. Test It

In SQL Editor:
```sql
-- Should return empty (no restaurants yet)
select * from restaurants limit 5;

-- Test the geo function exists
select PostGIS_Version();
```

---

## Schema Overview

```
profiles        → User data (extends auth.users)
restaurants     → Cached from Foursquare + user-submitted
dishes          → User-submitted menu items
ratings         → The star ratings + reviews
rating_photos   → Photos attached to ratings  
helpful_votes   → "Helpful" button tracking
favorites       → Saved restaurants
```

## Next Steps

Once Supabase is set up:
1. Seed Alexandria restaurants from Foursquare
2. Update iOS app to use Supabase SDK
3. Add real auth flow
