# Admin Dashboard Testing Guide

## Quick Start

1. **Open the dashboard locally:**
   ```bash
   open admin/index.html
   ```
   Or use a local server:
   ```bash
   cd admin
   python3 -m http.server 8000
   # Then visit http://localhost:8000
   ```

2. **Login:**
   - Default password: `clnk2024`
   - For production, change this in `app.js` or implement proper Supabase Auth

3. **Test Features:**
   - ✅ Stats Overview - Should show counts from database
   - ✅ Reports tab - View and manage reported reviews
   - ✅ Blocked Users - See all block relationships
   - ✅ Filter reports by status (pending/reviewed/dismissed/actioned)
   - ✅ Take actions on reports (mark reviewed, dismiss, hide review)

## Supabase Connection

The dashboard connects to:
- **URL:** `https://rbeuvvttiyxrdsgkrwaa.supabase.co`
- **Tables used:** `restaurants`, `dishes`, `ratings`, `profiles`, `reports`, `blocked_users`

## What to Check

1. **Login screen displays** with Clnk branding (teal theme)
2. **Stats load correctly** from Supabase
3. **Reports display** with all details:
   - Reporter username
   - Reported user username
   - Review content and rating
   - Report reason and details
   - Status badge
4. **Action buttons work**:
   - Mark as Reviewed (changes status)
   - Dismiss (changes status)
   - Take Action (changes status AND hides the rating)
5. **Blocked users list** shows blocker/blocked pairs
6. **Mobile responsive** - test on different screen sizes

## Troubleshooting

**Stats show 0 or loading forever:**
- Check browser console for errors
- Verify Supabase credentials in `app.js`
- Check that tables exist in Supabase

**Can't login:**
- Default password is `clnk2024`
- Check browser console

**Reports not showing:**
- Verify `reports` table has data
- Check browser console for SQL errors

## Production Deployment

### Option 1: GitHub Pages
```bash
# In repo settings, enable GitHub Pages
# Set source to: main branch / admin folder
# Dashboard will be at: https://bendichter.github.io/Clnk/
```

### Option 2: Netlify/Vercel
- Deploy the `/admin` folder
- Set build command: none (static site)
- Set publish directory: `admin`

### Security for Production

**Important:** Replace the simple password with proper authentication:

1. **Supabase Auth:**
   ```javascript
   // In app.js, replace checkAuth() with:
   const { data: { session } } = await supabase.auth.getSession();
   if (!session) {
       // Show Supabase login UI
   }
   ```

2. **Row Level Security:**
   - Create an `admin_users` table
   - Add RLS policies to restrict access
   - Check user role before showing admin dashboard

3. **Environment Variables:**
   - Don't expose anon key in production
   - Use Supabase service role key for admin operations
   - Implement backend API for sensitive operations
