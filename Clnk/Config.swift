import Foundation

/// App configuration - Supabase credentials and other settings
enum Config {
    // MARK: - Supabase Configuration
    
    /// Supabase project URL
    static let supabaseURL = "https://rbeuvvttiyxrdsgkrwaa.supabase.co"

    /// Supabase anonymous (public) key - safe to include in client apps
    static let supabaseAnonKey = "sb_publishable_eg3URPxXfuPzsFol-kyAIg_fqlUhQ7P"
    
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
