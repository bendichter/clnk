import Foundation

/// App configuration - Supabase credentials and other settings
enum Config {
    // MARK: - Supabase Configuration
    
    /// Supabase project URL
    static let supabaseURL = "https://kgfdwcsydjzioqdlovjy.supabase.co"
    
    /// Supabase anonymous (public) key - safe to include in client apps
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnZmR3Y3N5ZGp6aW9xZGxvdmp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5OTczNzAsImV4cCI6MjA4NTU3MzM3MH0.uvtdiHxGpMiyOdH618Hr2nrPtb3GHOsoQqm_PpRT1N4"
    
    // MARK: - Storage Configuration
    
    /// Storage bucket for rating photos
    static let ratingPhotosBucket = "rating-photos"
    
    /// Storage bucket for user avatars
    static let avatarsBucket = "avatars"
    
    /// Storage bucket for menu uploads (for AI extraction)
    static let menuUploadsBucket = "menu-uploads"
    
    // MARK: - API Configuration
    
    /// Default search radius in meters (5km)
    static let defaultSearchRadius: Int = 5000
    
    /// Maximum items per page for pagination
    static let defaultPageSize: Int = 20
}
