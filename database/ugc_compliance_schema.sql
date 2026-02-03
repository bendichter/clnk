-- UGC Compliance Database Schema for BiteVue
-- App Store Guidelines 1.2 Compliance
-- Run this SQL in Supabase SQL Editor to create the required tables

-- =====================================================
-- 1. Reports Table
-- =====================================================
-- Stores user reports of inappropriate reviews/ratings
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating_id UUID NOT NULL REFERENCES ratings(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'dismissed', 'actioned')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_rating ON reports(rating_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- Enable Row Level Security
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reports
-- Users can create reports for any rating
CREATE POLICY "Users can create reports" ON reports
    FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

-- Users can view their own reports
CREATE POLICY "Users can view own reports" ON reports
    FOR SELECT
    USING (auth.uid() = reporter_id);

-- Moderators/admins can view all reports (add role check as needed)
-- CREATE POLICY "Admins can view all reports" ON reports
--     FOR SELECT
--     USING (auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- 2. Blocked Users Table
-- =====================================================
-- Stores user blocking relationships
CREATE TABLE IF NOT EXISTS blocked_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id),
    CHECK (blocker_id != blocked_id)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_blocked_users_blocker ON blocked_users(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocked_users_blocked ON blocked_users(blocked_id);

-- Enable Row Level Security
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for blocked_users
-- Users can view users they have blocked
CREATE POLICY "Users can view their blocks" ON blocked_users
    FOR SELECT
    USING (auth.uid() = blocker_id);

-- Users can block other users
CREATE POLICY "Users can block others" ON blocked_users
    FOR INSERT
    WITH CHECK (auth.uid() = blocker_id AND blocker_id != blocked_id);

-- Users can unblock users they have blocked
CREATE POLICY "Users can unblock" ON blocked_users
    FOR DELETE
    USING (auth.uid() = blocker_id);

-- =====================================================
-- 3. Optional: Add is_hidden field to ratings table
-- =====================================================
-- Uncomment if you want to mark ratings as hidden (auto-moderation)
-- ALTER TABLE ratings ADD COLUMN IF NOT EXISTS is_hidden BOOLEAN DEFAULT FALSE;
-- ALTER TABLE ratings ADD COLUMN IF NOT EXISTS hidden_reason TEXT;
-- CREATE INDEX IF NOT EXISTS idx_ratings_is_hidden ON ratings(is_hidden);

-- =====================================================
-- 4. Optional: Trigger to auto-hide highly reported content
-- =====================================================
-- Automatically hide ratings with 3+ reports
-- Uncomment to enable auto-moderation

/*
CREATE OR REPLACE FUNCTION check_rating_reports()
RETURNS TRIGGER AS $$
BEGIN
    -- Count pending reports for this rating
    IF (SELECT COUNT(*) FROM reports 
        WHERE rating_id = NEW.rating_id 
        AND status = 'pending') >= 3 THEN
        
        -- Update the rating to be hidden
        UPDATE ratings 
        SET is_hidden = TRUE,
            hidden_reason = 'Multiple reports received'
        WHERE id = NEW.rating_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_rating_reports
    AFTER INSERT ON reports
    FOR EACH ROW
    EXECUTE FUNCTION check_rating_reports();
*/

-- =====================================================
-- 5. Helper Views (Optional)
-- =====================================================
-- View to see report statistics by rating
CREATE OR REPLACE VIEW rating_report_stats AS
SELECT 
    rating_id,
    COUNT(*) as total_reports,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_reports,
    COUNT(*) FILTER (WHERE status = 'actioned') as actioned_reports,
    MIN(created_at) as first_report_date,
    MAX(created_at) as latest_report_date
FROM reports
GROUP BY rating_id;

-- =====================================================
-- 6. Grant Permissions
-- =====================================================
-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE ON reports TO authenticated;
GRANT SELECT, INSERT, DELETE ON blocked_users TO authenticated;
GRANT SELECT ON rating_report_stats TO authenticated;

-- =====================================================
-- 7. Realtime subscriptions (Optional)
-- =====================================================
-- Enable realtime for moderators to see new reports
-- ALTER PUBLICATION supabase_realtime ADD TABLE reports;

-- =====================================================
-- 8. Test the schema
-- =====================================================
-- Run these queries to verify everything is working:
/*
-- Test report creation
INSERT INTO reports (reporter_id, rating_id, reason, details)
VALUES (auth.uid(), 'some-rating-uuid', 'Inappropriate content', 'Test report');

-- Test blocking
INSERT INTO blocked_users (blocker_id, blocked_id)
VALUES (auth.uid(), 'some-user-uuid');

-- View your reports
SELECT * FROM reports WHERE reporter_id = auth.uid();

-- View blocked users
SELECT * FROM blocked_users WHERE blocker_id = auth.uid();
*/

-- =====================================================
-- DONE! Schema created successfully
-- =====================================================
