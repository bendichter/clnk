-- Migration: User Following System
-- Description: Add ability for users to follow other users

-- Create user_follows table
CREATE TABLE IF NOT EXISTS user_follows (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    follower_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Prevent self-following
    CONSTRAINT no_self_follow CHECK (follower_id != following_id),
    
    -- Prevent duplicate follows
    UNIQUE(follower_id, following_id)
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_created_at ON user_follows(created_at DESC);

-- Enable RLS
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all follows (public for activity feeds)
CREATE POLICY "User follows are viewable by everyone"
    ON user_follows FOR SELECT
    USING (true);

-- Policy: Users can only create follows where they are the follower
CREATE POLICY "Users can follow others"
    ON user_follows FOR INSERT
    WITH CHECK (auth.uid() = follower_id);

-- Policy: Users can only delete their own follows
CREATE POLICY "Users can unfollow"
    ON user_follows FOR DELETE
    USING (auth.uid() = follower_id);

-- Create function to get follower count
CREATE OR REPLACE FUNCTION get_follower_count(user_id UUID)
RETURNS BIGINT AS $$
    SELECT COUNT(*) FROM user_follows WHERE following_id = user_id;
$$ LANGUAGE SQL STABLE;

-- Create function to get following count  
CREATE OR REPLACE FUNCTION get_following_count(user_id UUID)
RETURNS BIGINT AS $$
    SELECT COUNT(*) FROM user_follows WHERE follower_id = user_id;
$$ LANGUAGE SQL STABLE;

-- Create function to check if user is following another
CREATE OR REPLACE FUNCTION is_following(follower UUID, target UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS(
        SELECT 1 FROM user_follows 
        WHERE follower_id = follower AND following_id = target
    );
$$ LANGUAGE SQL STABLE;

-- Comment on table
COMMENT ON TABLE user_follows IS 'Tracks user follow relationships for social activity feeds';
