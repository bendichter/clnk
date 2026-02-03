-- Menu AI Feature Migration
-- Allows restaurant owners to upload menus and have AI extract dishes

-- Create menu_uploads table
CREATE TABLE IF NOT EXISTS menu_uploads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES profiles(id),
    storage_path TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL, -- 'image/jpeg', 'image/png', 'application/pdf'
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    page_count INTEGER DEFAULT 1 CHECK (page_count > 0 AND page_count <= 20),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    
    CONSTRAINT valid_file_type CHECK (file_type IN ('image/jpeg', 'image/png', 'application/pdf'))
);

-- Create menu_extractions table
CREATE TABLE IF NOT EXISTS menu_extractions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_upload_id UUID NOT NULL REFERENCES menu_uploads(id) ON DELETE CASCADE,
    extracted_dishes JSONB NOT NULL DEFAULT '[]',
    -- JSONB structure: [{name, description, price, category, dietary_tags}]
    confidence_score DECIMAL(3,2), -- 0.00 to 1.00
    processing_time_ms INTEGER,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES profiles(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_menu_uploads_restaurant ON menu_uploads(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_menu_uploads_status ON menu_uploads(status);
CREATE INDEX IF NOT EXISTS idx_menu_uploads_created ON menu_uploads(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_menu_extractions_upload ON menu_extractions(menu_upload_id);

-- RLS Policies: Only restaurant owners can upload menus

-- Enable RLS
ALTER TABLE menu_uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_extractions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own uploads
CREATE POLICY "Users can view own uploads"
    ON menu_uploads
    FOR SELECT
    USING (auth.uid() = uploaded_by);

-- Policy: Users can insert uploads for restaurants they own
-- Note: This requires checking restaurant ownership via restaurants table
CREATE POLICY "Restaurant owners can upload menus"
    ON menu_uploads
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL AND
        EXISTS (
            SELECT 1 FROM restaurants 
            WHERE id = menu_uploads.restaurant_id 
            AND submitted_by = auth.uid()
        )
    );

-- Policy: Service role can update all uploads (for Edge Function processing)
CREATE POLICY "Service role can update uploads"
    ON menu_uploads
    FOR UPDATE
    USING (true);

-- Policy: Users can view extractions for their uploads
CREATE POLICY "Users can view own extractions"
    ON menu_extractions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM menu_uploads 
            WHERE id = menu_extractions.menu_upload_id 
            AND uploaded_by = auth.uid()
        )
    );

-- Policy: Service role can insert extractions
CREATE POLICY "Service role can insert extractions"
    ON menu_extractions
    FOR INSERT
    WITH CHECK (true);

-- Policy: Users can update their extractions (for approval)
CREATE POLICY "Users can update own extractions"
    ON menu_extractions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM menu_uploads 
            WHERE id = menu_extractions.menu_upload_id 
            AND uploaded_by = auth.uid()
        )
    );

-- Function to check rate limit (20 uploads per restaurant per day)
CREATE OR REPLACE FUNCTION check_menu_upload_rate_limit(
    p_restaurant_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    upload_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO upload_count
    FROM menu_uploads
    WHERE restaurant_id = p_restaurant_id
      AND created_at > NOW() - INTERVAL '24 hours';
    
    RETURN upload_count < 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to enforce rate limit before insert
CREATE OR REPLACE FUNCTION enforce_menu_upload_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT check_menu_upload_rate_limit(NEW.restaurant_id) THEN
        RAISE EXCEPTION 'Rate limit exceeded: Maximum 20 menu uploads per restaurant per day';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_enforce_menu_upload_rate_limit
    BEFORE INSERT ON menu_uploads
    FOR EACH ROW
    EXECUTE FUNCTION enforce_menu_upload_rate_limit();

-- Function to check for duplicate dish names (for warnings)
CREATE OR REPLACE FUNCTION check_duplicate_dish_names(
    p_restaurant_id UUID,
    p_dish_names TEXT[]
) RETURNS TABLE(dish_name TEXT, already_exists BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        unnest(p_dish_names) AS dish_name,
        EXISTS (
            SELECT 1 FROM dishes d
            WHERE d.restaurant_id = p_restaurant_id 
            AND LOWER(d.name) = LOWER(unnest(p_dish_names))
        ) AS already_exists;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION check_menu_upload_rate_limit(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION check_duplicate_dish_names(UUID, TEXT[]) TO authenticated;

-- Comments for documentation
COMMENT ON TABLE menu_uploads IS 'Stores uploaded menu images/PDFs for AI processing';
COMMENT ON TABLE menu_extractions IS 'Stores AI-extracted dish information from menus';
COMMENT ON COLUMN menu_uploads.page_count IS 'Number of pages (for PDFs), max 20';
COMMENT ON COLUMN menu_extractions.extracted_dishes IS 'Array of extracted dish objects with name, description, price, category, dietary_tags';
