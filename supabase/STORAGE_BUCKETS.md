# Supabase Storage Buckets Configuration

This document describes the storage buckets used in the Clnk app.

## Buckets

### 1. `menu-uploads`
**Purpose:** Store uploaded menu images and PDFs for AI extraction

**Configuration:**
- **Public:** Yes (files need to be publicly accessible for AI processing)
- **File size limit:** 10MB
- **Allowed MIME types:**
  - `image/jpeg`
  - `image/png`
  - `application/pdf`
- **File name patterns:** `{restaurant_id}/menu_{timestamp}.{ext}`

**RLS Policies:**
- **Upload:** Only authenticated users who own the restaurant
- **Read:** Public (for AI processing)
- **Delete:** Only file owner or service role

**Setup via Supabase Dashboard:**
1. Go to Storage → Create new bucket
2. Name: `menu-uploads`
3. Set as Public bucket
4. Add RLS policies:
   ```sql
   -- Allow authenticated users to upload to their restaurant folders
   CREATE POLICY "Users can upload menus"
   ON storage.objects FOR INSERT
   WITH CHECK (
     bucket_id = 'menu-uploads' AND
     auth.uid()::text = (storage.foldername(name))[1]
   );
   
   -- Allow public read access
   CREATE POLICY "Public read access"
   ON storage.objects FOR SELECT
   USING (bucket_id = 'menu-uploads');
   
   -- Allow users to delete their own files
   CREATE POLICY "Users can delete own files"
   ON storage.objects FOR DELETE
   USING (
     bucket_id = 'menu-uploads' AND
     auth.uid()::text = (storage.foldername(name))[1]
   );
   ```

### 2. `rating-photos` (existing)
**Purpose:** Store user-uploaded photos of dishes in ratings

**Configuration:**
- **Public:** Yes
- **File size limit:** 5MB
- **Allowed MIME types:** `image/jpeg`, `image/png`

### 3. `avatars` (existing)
**Purpose:** Store user profile avatars

**Configuration:**
- **Public:** Yes
- **File size limit:** 2MB
- **Allowed MIME types:** `image/jpeg`, `image/png`

## Configuration via Supabase CLI

To create the menu-uploads bucket via CLI:

```bash
# Make sure you're in the project directory
cd supabase

# Create the bucket (run this command manually in Supabase dashboard or via SQL)
# Or add to a migration file:
```

```sql
-- Create menu-uploads bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'menu-uploads',
  'menu-uploads',
  true,
  10485760, -- 10MB in bytes
  ARRAY['image/jpeg', 'image/png', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;
```

## Environment Variables

Make sure the following environment variables are set for the Edge Function:

```bash
# Supabase secrets (managed via Supabase dashboard)
ANTHROPIC_API_KEY=sk-ant-xxxxx...

# These are automatically available:
# SUPABASE_URL
# SUPABASE_SERVICE_ROLE_KEY
```

To set the Anthropic API key:
```bash
supabase secrets set ANTHROPIC_API_KEY=sk-ant-xxxxx
```
