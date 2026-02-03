# Clnk - Supabase Setup Guide

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click **New Project**
3. Fill in:
   - **Name:** Clnk
   - **Database Password:** (save this!)
   - **Region:** East US (or closest)
4. Click **Create new project**

## 2. Get Project Credentials

After creation, go to **Settings → API**:

- **Project URL:** `https://xxxxx.supabase.co`
- **anon public key:** `eyJhbGci...` (the long one)

## 3. Run Database Schema

1. Go to **SQL Editor** in Supabase Dashboard
2. Copy contents of `supabase/schema_clnk.sql`
3. Run the query

## 4. Import Mock Data

1. Go to **SQL Editor**
2. Copy contents of `supabase/mock_data.sql`
3. Run the query

## 5. Create Storage Bucket (for photos)

1. Go to **Storage**
2. Click **New Bucket**
3. Name: `cocktail-photos`
4. Public: ✅ Yes

## 6. Update App Config

Update `Clnk/Config.swift` with your credentials:

```swift
struct Config {
    static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
    static let supabaseAnonKey = "YOUR_ANON_KEY"
}
```

## 7. Test Connection

Build and run the app - it should load the 10 sample bars and 45+ cocktails!

---

## Quick Stats

- **10 Bars** across different styles (Classic, Tiki, Modern, Whiskey, Gin, Wine, Tequila)
- **45+ Cocktails** with descriptions and prices
- Prices range from $6 (dive bar) to $26 (molecular mixology)
- Featured bars highlighted on home screen

## Database Tables

| Table | Purpose |
|-------|---------|
| `profiles` | User accounts |
| `venues` | Bars/lounges |
| `cocktails` | Drinks at each venue |
| `ratings` | User reviews |
| `rating_photos` | Review photos |
| `favorites` | User favorites |
| `reports` | Content moderation |
| `blocked_users` | User blocks |
