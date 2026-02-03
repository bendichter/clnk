import Foundation
import Supabase

/// Singleton Supabase client instance for the app
final class SupabaseClientManager {
    
    /// Shared instance
    static let shared = SupabaseClientManager()
    
    /// The Supabase client
    let client: SupabaseClient
    
    private init() {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL in Config")
        }
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    // MARK: - Convenience Accessors
    
    /// Auth client for authentication
    var auth: AuthClient {
        client.auth
    }
    
    /// Storage client for file uploads
    var storage: SupabaseStorageClient {
        client.storage
    }
    
    /// Realtime client for subscriptions (if needed)
    var realtime: RealtimeClientV2 {
        client.realtimeV2
    }
}
