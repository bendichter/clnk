import Foundation
import CoreLocation
import Supabase

// MARK: - Supabase Response Models

/// Profile response from Supabase
struct SupabaseProfile: Codable {
    let id: UUID
    let username: String?
    let fullName: String?
    let bio: String?
    let avatarEmoji: String?
    let avatarUrl: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case bio
        case avatarEmoji = "avatar_emoji"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Restaurant response from Supabase
struct SupabaseRestaurant: Codable, Identifiable {
    let id: UUID
    let fsqPlaceId: String?
    let name: String
    let address: String?
    let locality: String?
    let region: String?
    let postcode: String?
    let country: String?
    let formattedAddress: String?
    let latitude: Double?
    let longitude: Double?
    let cuisineType: String?
    let categories: [String: Any]?
    let phone: String?
    let website: String?
    let email: String?
    let photoUrl: String?
    let isUserSubmitted: Bool?
    let submittedBy: UUID?
    let createdAt: Date?
    let updatedAt: Date?
    
    // Nested dishes (when joined)
    var dishes: [SupabaseDish]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fsqPlaceId = "fsq_place_id"
        case name
        case address
        case locality
        case region
        case postcode
        case country
        case formattedAddress = "formatted_address"
        case latitude
        case longitude
        case cuisineType = "cuisine_type"
        case phone
        case website
        case email
        case photoUrl = "photo_url"
        case isUserSubmitted = "is_user_submitted"
        case submittedBy = "submitted_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case dishes
    }
    
    // Custom decoding to handle categories JSONB
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fsqPlaceId = try container.decodeIfPresent(String.self, forKey: .fsqPlaceId)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        locality = try container.decodeIfPresent(String.self, forKey: .locality)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        postcode = try container.decodeIfPresent(String.self, forKey: .postcode)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        formattedAddress = try container.decodeIfPresent(String.self, forKey: .formattedAddress)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        cuisineType = try container.decodeIfPresent(String.self, forKey: .cuisineType)
        categories = nil // Skip complex JSONB parsing for now
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        isUserSubmitted = try container.decodeIfPresent(Bool.self, forKey: .isUserSubmitted)
        submittedBy = try container.decodeIfPresent(UUID.self, forKey: .submittedBy)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        dishes = try container.decodeIfPresent([SupabaseDish].self, forKey: .dishes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(fsqPlaceId, forKey: .fsqPlaceId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(locality, forKey: .locality)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(postcode, forKey: .postcode)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(formattedAddress, forKey: .formattedAddress)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(cuisineType, forKey: .cuisineType)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(isUserSubmitted, forKey: .isUserSubmitted)
        try container.encodeIfPresent(submittedBy, forKey: .submittedBy)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(dishes, forKey: .dishes)
    }
}

/// Dish response from Supabase
struct SupabaseDish: Codable, Identifiable {
    let id: UUID
    let restaurantId: UUID
    let name: String
    let description: String?
    let price: Double?
    let category: String?
    let dietaryTags: [String]?
    let photoUrl: String?
    let submittedBy: UUID?
    let isVerified: Bool?
    let avgRating: Double?
    let ratingCount: Int?
    let createdAt: Date?
    let updatedAt: Date?
    
    // Nested ratings (when joined)
    var ratings: [SupabaseRating]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case restaurantId = "restaurant_id"
        case name
        case description
        case price
        case category
        case dietaryTags = "dietary_tags"
        case photoUrl = "photo_url"
        case submittedBy = "submitted_by"
        case isVerified = "is_verified"
        case avgRating = "avg_rating"
        case ratingCount = "rating_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case ratings
    }
}

/// Rating response from Supabase
struct SupabaseRating: Codable, Identifiable {
    let id: UUID
    let dishId: UUID
    let userId: UUID
    let rating: Int
    let comment: String?
    let helpfulCount: Int?
    let createdAt: Date?
    let updatedAt: Date?
    
    // Nested profile (when joined)
    var profile: SupabaseProfile?
    
    // Nested photos (when joined)
    var photos: [SupabaseRatingPhoto]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case dishId = "dish_id"
        case userId = "user_id"
        case rating
        case comment
        case helpfulCount = "helpful_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profile = "profiles"
        case photos = "rating_photos"
    }
}

/// Rating photo from Supabase
struct SupabaseRatingPhoto: Codable, Identifiable {
    let id: UUID
    let ratingId: UUID
    let photoUrl: String
    let storagePath: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ratingId = "rating_id"
        case photoUrl = "photo_url"
        case storagePath = "storage_path"
        case createdAt = "created_at"
    }
}

/// Favorite from Supabase
struct SupabaseFavorite: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let restaurantId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case restaurantId = "restaurant_id"
        case createdAt = "created_at"
    }
}

/// Helpful vote from Supabase
struct SupabaseHelpfulVote: Codable, Identifiable {
    let id: UUID
    let ratingId: UUID
    let userId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ratingId = "rating_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - Insert Models (for creating records)

struct NewDish: Codable {
    let restaurantId: UUID
    let name: String
    let description: String?
    let price: Double?
    let category: String?
    let dietaryTags: [String]?
    let submittedBy: UUID?
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case name
        case description
        case price
        case category
        case dietaryTags = "dietary_tags"
        case submittedBy = "submitted_by"
    }
}

struct NewRating: Codable {
    let dishId: UUID
    let userId: UUID
    let rating: Int
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case dishId = "dish_id"
        case userId = "user_id"
        case rating
        case comment
    }
}

struct NewRatingPhoto: Codable {
    let ratingId: UUID
    let photoUrl: String
    let storagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case ratingId = "rating_id"
        case photoUrl = "photo_url"
        case storagePath = "storage_path"
    }
}

struct NewFavorite: Codable {
    let userId: UUID
    let restaurantId: UUID
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case restaurantId = "restaurant_id"
    }
}

struct NewHelpfulVote: Codable {
    let ratingId: UUID
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case ratingId = "rating_id"
        case userId = "user_id"
    }
}

// MARK: - UGC Compliance Models

struct NewBlockedUser: Codable {
    let blockerId: UUID
    let blockedId: UUID
    
    enum CodingKeys: String, CodingKey {
        case blockerId = "blocker_id"
        case blockedId = "blocked_id"
    }
}

struct SupabaseBlockedUser: Codable, Identifiable {
    let id: UUID
    let blockerId: UUID
    let blockedId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case blockerId = "blocker_id"
        case blockedId = "blocked_id"
        case createdAt = "created_at"
    }
}

// MARK: - User Follow Models
struct NewUserFollow: Codable {
    let followerId: UUID
    let followingId: UUID
    
    enum CodingKeys: String, CodingKey {
        case followerId = "follower_id"
        case followingId = "following_id"
    }
}

struct SupabaseUserFollow: Codable, Identifiable {
    let id: UUID
    let followerId: UUID
    let followingId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case followerId = "follower_id"
        case followingId = "following_id"
        case createdAt = "created_at"
    }
}

struct NewReport: Codable {
    let reporterId: UUID
    let ratingId: UUID
    let reason: String
    let details: String?
    
    enum CodingKeys: String, CodingKey {
        case reporterId = "reporter_id"
        case ratingId = "rating_id"
        case reason
        case details
    }
}

struct SupabaseReport: Codable, Identifiable {
    let id: UUID
    let reporterId: UUID
    let ratingId: UUID
    let reason: String
    let details: String?
    let status: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case reporterId = "reporter_id"
        case ratingId = "rating_id"
        case reason
        case details
        case status
        case createdAt = "created_at"
    }
}

struct RatingUpdate: Codable {
    let rating: Int
    let comment: String
}

// MARK: - Menu Upload Models

/// Menu upload record from Supabase
struct MenuUpload: Codable, Identifiable {
    let id: UUID
    let restaurantId: UUID
    let uploadedBy: UUID
    let storagePath: String
    let fileUrl: String
    let fileType: String
    let status: String
    let pageCount: Int?
    let errorMessage: String?
    let createdAt: Date?
    let processedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case restaurantId = "restaurant_id"
        case uploadedBy = "uploaded_by"
        case storagePath = "storage_path"
        case fileUrl = "file_url"
        case fileType = "file_type"
        case status
        case pageCount = "page_count"
        case errorMessage = "error_message"
        case createdAt = "created_at"
        case processedAt = "processed_at"
    }
}

/// Menu extraction result from Supabase
struct MenuExtraction: Codable, Identifiable {
    let id: UUID
    let menuUploadId: UUID
    var extractedDishes: [ExtractedDish]
    let confidenceScore: Double?
    let processingTimeMs: Int?
    let status: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case menuUploadId = "menu_upload_id"
        case extractedDishes = "extracted_dishes"
        case confidenceScore = "confidence_score"
        case processingTimeMs = "processing_time_ms"
        case status
        case createdAt = "created_at"
    }
}

/// Extracted dish from AI analysis
struct ExtractedDish: Codable, Identifiable, Equatable {
    var id = UUID() // Client-side ID for editing
    var name: String
    var description: String
    var price: Double
    var category: String
    var dietaryTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, description, price, category
        case dietaryTags = "dietary_tags"
    }
    
    // Custom init to handle missing id from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0
        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Main Courses"
        self.dietaryTags = try container.decodeIfPresent([String].self, forKey: .dietaryTags) ?? []
    }
    
    // Explicit initializer for creating instances
    init(id: UUID = UUID(), name: String, description: String, price: Double, category: String, dietaryTags: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.dietaryTags = dietaryTags
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(category, forKey: .category)
        try container.encode(dietaryTags, forKey: .dietaryTags)
    }
}

struct NewMenuUpload: Codable {
    let restaurantId: UUID
    let uploadedBy: UUID
    let storagePath: String
    let fileUrl: String
    let fileType: String
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case uploadedBy = "uploaded_by"
        case storagePath = "storage_path"
        case fileUrl = "file_url"
        case fileType = "file_type"
    }
}

// MARK: - Service Error

enum SupabaseServiceError: LocalizedError {
    case notAuthenticated
    case networkError(Error)
    case decodingError(Error)
    case uploadError(String)
    case notFound
    case rateLimitExceeded
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .uploadError(let message):
            return "Upload failed: \(message)"
        case .notFound:
            return "Item not found"
        case .rateLimitExceeded:
            return "Rate limit exceeded: Maximum 20 menu uploads per restaurant per day"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Supabase Service

@MainActor
final class SupabaseService: ObservableObject {
    
    static let shared = SupabaseService()
    
    private let client = SupabaseClientManager.shared.client
    
    private init() {}
    
    // MARK: - Restaurants
    
    /// Fetch restaurants near a location
    func fetchRestaurants(
        near coordinate: CLLocationCoordinate2D,
        radius: Int = Config.defaultSearchRadius
    ) async throws -> [SupabaseRestaurant] {
        // Using PostGIS ST_DWithin for geo queries
        // For now, fetch all and filter client-side since we need to handle the RPC
        do {
            let restaurants: [SupabaseRestaurant] = try await client
                .from("restaurants")
                .select()
                .execute()
                .value
            
            // Filter by distance client-side
            let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let filtered = restaurants.filter { restaurant in
                guard let lat = restaurant.latitude, let lng = restaurant.longitude else { return false }
                let restaurantLocation = CLLocation(latitude: lat, longitude: lng)
                let distance = userLocation.distance(from: restaurantLocation)
                return distance <= Double(radius)
            }
            
            return filtered
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Fetch all restaurants (no location filter)
    func fetchAllRestaurants() async throws -> [SupabaseRestaurant] {
        do {
            let restaurants: [SupabaseRestaurant] = try await client
                .from("restaurants")
                .select()
                .order("name")
                .execute()
                .value
            
            return restaurants
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Fetch a single restaurant by ID with its dishes
    func fetchRestaurant(id: UUID) async throws -> SupabaseRestaurant {
        do {
            let restaurant: SupabaseRestaurant = try await client
                .from("restaurants")
                .select("*, dishes(*)")
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
            
            return restaurant
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Dishes
    
    /// Fetch dishes for a restaurant
    func fetchDishes(restaurantId: UUID) async throws -> [SupabaseDish] {
        do {
            let dishes: [SupabaseDish] = try await client
                .from("dishes")
                .select("*, ratings(*, profiles(*), rating_photos(*))")
                .eq("restaurant_id", value: restaurantId.uuidString)
                .order("name")
                .execute()
                .value
            
            return dishes
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Fetch a single dish by ID with ratings
    func fetchDish(id: UUID) async throws -> SupabaseDish {
        do {
            let dish: SupabaseDish = try await client
                .from("dishes")
                .select("*, ratings(*, profiles(*), rating_photos(*))")
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
            
            return dish
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Add a new dish to a restaurant
    func addDish(
        restaurantId: UUID,
        name: String,
        description: String? = nil,
        category: String? = nil,
        price: Double? = nil,
        dietaryTags: [String]? = nil
    ) async throws -> SupabaseDish {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        let newDish = NewDish(
            restaurantId: restaurantId,
            name: name,
            description: description,
            price: price,
            category: category,
            dietaryTags: dietaryTags,
            submittedBy: userId
        )
        
        do {
            let dish: SupabaseDish = try await client
                .from("dishes")
                .insert(newDish)
                .select()
                .single()
                .execute()
                .value
            
            return dish
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Ratings
    
    /// Fetch ratings for a dish
    func fetchRatings(dishId: UUID) async throws -> [SupabaseRating] {
        do {
            let ratings: [SupabaseRating] = try await client
                .from("ratings")
                .select("*, profiles(*), rating_photos(*)")
                .eq("dish_id", value: dishId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return ratings
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Submit a rating for a dish
    func submitRating(
        dishId: UUID,
        rating: Int,
        comment: String?,
        photoData: [Data]? = nil
    ) async throws -> SupabaseRating {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        let newRating = NewRating(
            dishId: dishId,
            userId: userId,
            rating: rating,
            comment: comment
        )
        
        do {
            // Insert the rating
            let createdRating: SupabaseRating = try await client
                .from("ratings")
                .insert(newRating)
                .select()
                .single()
                .execute()
                .value
            
            // Upload photos if provided
            if let photoData = photoData, !photoData.isEmpty {
                for (index, data) in photoData.enumerated() {
                    _ = try await uploadRatingPhoto(
                        ratingId: createdRating.id,
                        imageData: data,
                        index: index
                    )
                }
            }
            
            return createdRating
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Update an existing rating
    func updateRating(
        ratingId: UUID,
        rating: Int,
        comment: String?
    ) async throws -> SupabaseRating {
        guard client.auth.currentUser != nil else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        let updateData = RatingUpdate(rating: rating, comment: comment ?? "")
        
        do {
            let updatedRating: SupabaseRating = try await client
                .from("ratings")
                .update(updateData)
                .eq("id", value: ratingId.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            return updatedRating
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Delete a rating
    func deleteRating(ratingId: UUID) async throws {
        guard client.auth.currentUser != nil else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            try await client
                .from("ratings")
                .delete()
                .eq("id", value: ratingId.uuidString)
                .execute()
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Photo Upload
    
    /// Upload a photo for a rating
    func uploadRatingPhoto(
        ratingId: UUID,
        imageData: Data,
        index: Int = 0
    ) async throws -> SupabaseRatingPhoto {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        let fileName = "\(userId.uuidString)/\(ratingId.uuidString)_\(index)_\(Date().timeIntervalSince1970).jpg"
        
        do {
            // Upload to storage
            _ = try await client.storage
                .from(Config.ratingPhotosBucket)
                .upload(
                    fileName,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get public URL
            let publicUrl = try client.storage
                .from(Config.ratingPhotosBucket)
                .getPublicURL(path: fileName)
            
            // Create rating_photos record
            let newPhoto = NewRatingPhoto(
                ratingId: ratingId,
                photoUrl: publicUrl.absoluteString,
                storagePath: fileName
            )
            
            let photo: SupabaseRatingPhoto = try await client
                .from("rating_photos")
                .insert(newPhoto)
                .select()
                .single()
                .execute()
                .value
            
            return photo
        } catch {
            throw SupabaseServiceError.uploadError(error.localizedDescription)
        }
    }
    
    // MARK: - Favorites
    
    /// Fetch user's favorite restaurants
    func fetchFavorites() async throws -> [SupabaseFavorite] {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            let favorites: [SupabaseFavorite] = try await client
                .from("favorites")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            return favorites
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Toggle favorite status for a restaurant
    func toggleFavorite(restaurantId: UUID) async throws -> Bool {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            // Check if already favorited
            let existing: [SupabaseFavorite] = try await client
                .from("favorites")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("restaurant_id", value: restaurantId.uuidString)
                .execute()
                .value
            
            if existing.isEmpty {
                // Add favorite
                let newFavorite = NewFavorite(userId: userId, restaurantId: restaurantId)
                try await client
                    .from("favorites")
                    .insert(newFavorite)
                    .execute()
                return true
            } else {
                // Remove favorite
                try await client
                    .from("favorites")
                    .delete()
                    .eq("user_id", value: userId.uuidString)
                    .eq("restaurant_id", value: restaurantId.uuidString)
                    .execute()
                return false
            }
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Helpful Votes
    
    /// Fetch user's helpful votes
    func fetchHelpfulVotes() async throws -> [SupabaseHelpfulVote] {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            let votes: [SupabaseHelpfulVote] = try await client
                .from("helpful_votes")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            return votes
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Toggle helpful vote for a rating
    func toggleHelpful(ratingId: UUID) async throws -> Bool {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            // Check if already voted
            let existing: [SupabaseHelpfulVote] = try await client
                .from("helpful_votes")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("rating_id", value: ratingId.uuidString)
                .execute()
                .value
            
            if existing.isEmpty {
                // Add vote
                let newVote = NewHelpfulVote(ratingId: ratingId, userId: userId)
                try await client
                    .from("helpful_votes")
                    .insert(newVote)
                    .execute()
                return true
            } else {
                // Remove vote
                try await client
                    .from("helpful_votes")
                    .delete()
                    .eq("user_id", value: userId.uuidString)
                    .eq("rating_id", value: ratingId.uuidString)
                    .execute()
                return false
            }
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Profile
    
    /// Fetch current user's profile
    func fetchProfile() async throws -> SupabaseProfile? {
        guard let userId = client.auth.currentUser?.id else {
            return nil
        }
        
        do {
            let profile: SupabaseProfile = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            // Profile might not exist yet
            return nil
        }
    }
    
    /// Update user profile
    func updateProfile(
        username: String? = nil,
        fullName: String? = nil,
        bio: String? = nil,
        avatarEmoji: String? = nil,
        avatarUrl: String? = nil
    ) async throws -> SupabaseProfile {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        var updates: [String: String] = [:]
        if let username = username { updates["username"] = username }
        if let fullName = fullName { updates["full_name"] = fullName }
        if let bio = bio { updates["bio"] = bio }
        if let avatarEmoji = avatarEmoji { updates["avatar_emoji"] = avatarEmoji }
        if let avatarUrl = avatarUrl { updates["avatar_url"] = avatarUrl }
        
        do {
            let profile: SupabaseProfile = try await client
                .from("profiles")
                .update(updates)
                .eq("id", value: userId.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Upload avatar image
    func uploadAvatar(imageData: Data) async throws -> String {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        let fileName = "\(userId.uuidString)/avatar_\(Date().timeIntervalSince1970).jpg"
        
        do {
            _ = try await client.storage
                .from(Config.avatarsBucket)
                .upload(
                    fileName,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            let publicUrl = try client.storage
                .from(Config.avatarsBucket)
                .getPublicURL(path: fileName)
            
            // Update profile with new URL
            _ = try await updateProfile(avatarUrl: publicUrl.absoluteString)
            
            return publicUrl.absoluteString
        } catch {
            throw SupabaseServiceError.uploadError(error.localizedDescription)
        }
    }
    
    // MARK: - UGC Compliance: Block User
    
    /// Fetch blocked users for current user
    func fetchBlockedUsers() async throws -> [SupabaseBlockedUser] {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            let blocked: [SupabaseBlockedUser] = try await client
                .from("blocked_users")
                .select()
                .eq("blocker_id", value: userId.uuidString)
                .execute()
                .value
            
            return blocked
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Block a user
    func blockUser(userId: UUID) async throws -> Bool {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        // Check if already blocked
        let existing: [SupabaseBlockedUser] = try await client
            .from("blocked_users")
            .select()
            .eq("blocker_id", value: currentUserId.uuidString)
            .eq("blocked_id", value: userId.uuidString)
            .execute()
            .value
        
        if !existing.isEmpty {
            return true // Already blocked
        }
        
        let newBlock = NewBlockedUser(blockerId: currentUserId, blockedId: userId)
        
        do {
            try await client
                .from("blocked_users")
                .insert(newBlock)
                .execute()
            
            return true
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Unblock a user
    func unblockUser(userId: UUID) async throws -> Bool {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            try await client
                .from("blocked_users")
                .delete()
                .eq("blocker_id", value: currentUserId.uuidString)
                .eq("blocked_id", value: userId.uuidString)
                .execute()
            
            return true
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Following System
    
    /// Follow a user
    func followUser(userId: UUID) async throws -> Bool {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        // Check if already following
        let existing: [SupabaseUserFollow] = try await client
            .from("user_follows")
            .select()
            .eq("follower_id", value: currentUserId.uuidString)
            .eq("following_id", value: userId.uuidString)
            .execute()
            .value
        
        if !existing.isEmpty {
            return true // Already following
        }
        
        let newFollow = NewUserFollow(followerId: currentUserId, followingId: userId)
        
        do {
            try await client
                .from("user_follows")
                .insert(newFollow)
                .execute()
            
            return true
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Unfollow a user
    func unfollowUser(userId: UUID) async throws -> Bool {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            try await client
                .from("user_follows")
                .delete()
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("following_id", value: userId.uuidString)
                .execute()
            
            return true
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Fetch users the current user is following
    func fetchFollowing() async throws -> [SupabaseUserFollow] {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            let follows: [SupabaseUserFollow] = try await client
                .from("user_follows")
                .select()
                .eq("follower_id", value: currentUserId.uuidString)
                .execute()
                .value
            
            return follows
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Fetch users following the current user
    func fetchFollowers() async throws -> [SupabaseUserFollow] {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        do {
            let follows: [SupabaseUserFollow] = try await client
                .from("user_follows")
                .select()
                .eq("following_id", value: currentUserId.uuidString)
                .execute()
                .value
            
            return follows
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - UGC Compliance: Report Review
    
    /// Submit a report for a review
    func reportReview(
        ratingId: UUID,
        reason: String,
        details: String?
    ) async throws -> SupabaseReport {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        let newReport = NewReport(
            reporterId: userId,
            ratingId: ratingId,
            reason: reason,
            details: details
        )
        
        do {
            let report: SupabaseReport = try await client
                .from("reports")
                .insert(newReport)
                .select()
                .single()
                .execute()
                .value
            
            return report
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    // MARK: - Menu Upload & Extraction
    
    /// Upload a menu image/PDF and trigger AI extraction
    func uploadMenu(
        restaurantId: UUID,
        imageData: Data,
        fileType: String = "image/jpeg"
    ) async throws -> MenuUpload {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        // 1. Upload to storage
        let fileExtension: String
        switch fileType {
        case "image/jpeg": fileExtension = "jpg"
        case "image/png": fileExtension = "png"
        case "application/pdf": fileExtension = "pdf"
        default: fileExtension = "jpg"
        }
        
        let fileName = "\(restaurantId.uuidString)/menu_\(Date().timeIntervalSince1970).\(fileExtension)"
        
        do {
            _ = try await client.storage
                .from("menu-uploads")
                .upload(fileName, data: imageData, options: FileOptions(contentType: fileType))
            
            let publicUrl = try client.storage
                .from("menu-uploads")
                .getPublicURL(path: fileName)
            
            // 2. Create menu_upload record
            let newUpload = NewMenuUpload(
                restaurantId: restaurantId,
                uploadedBy: userId,
                storagePath: fileName,
                fileUrl: publicUrl.absoluteString,
                fileType: fileType
            )
            
            let upload: MenuUpload = try await client
                .from("menu_uploads")
                .insert(newUpload)
                .select()
                .single()
                .execute()
                .value
            
            // 3. Trigger Edge Function for processing
            try await triggerMenuExtraction(
                uploadId: upload.id,
                fileUrl: publicUrl.absoluteString,
                fileType: fileType
            )
            
            return upload
        } catch {
            // Check if it's a rate limit error
            let errorString = error.localizedDescription.lowercased()
            if errorString.contains("rate limit") {
                throw SupabaseServiceError.rateLimitExceeded
            }
            throw SupabaseServiceError.uploadError(error.localizedDescription)
        }
    }
    
    /// Trigger the Edge Function to extract menu items
    private func triggerMenuExtraction(uploadId: UUID, fileUrl: String, fileType: String) async throws {
        struct ExtractionRequest: Codable {
            let menu_upload_id: String
            let file_url: String
            let file_type: String
        }
        
        let request = ExtractionRequest(
            menu_upload_id: uploadId.uuidString,
            file_url: fileUrl,
            file_type: fileType
        )
        
        do {
            let requestData = try JSONEncoder().encode(request)
            
            // Call Edge Function
            try await client.functions.invoke(
                "extract-menu",
                options: FunctionInvokeOptions(body: requestData)
            )
        } catch {
            print("Error triggering extraction: \(error)")
            // Don't fail the entire upload if edge function trigger fails
            // The extraction can be retried manually
        }
    }
    
    /// Fetch extraction results for a menu upload
    func fetchMenuExtraction(uploadId: UUID) async throws -> MenuExtraction? {
        do {
            let extractions: [MenuExtraction] = try await client
                .from("menu_extractions")
                .select()
                .eq("menu_upload_id", value: uploadId.uuidString)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            
            return extractions.first
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Check status of menu upload
    func fetchMenuUpload(id: UUID) async throws -> MenuUpload {
        do {
            let upload: MenuUpload = try await client
                .from("menu_uploads")
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
            
            return upload
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
    
    /// Save approved dishes from extraction
    func saveExtractedDishes(
        restaurantId: UUID,
        dishes: [ExtractedDish],
        extractionId: UUID
    ) async throws -> [SupabaseDish] {
        guard let userId = client.auth.currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        
        var savedDishes: [SupabaseDish] = []
        
        for dish in dishes {
            let newDish = NewDish(
                restaurantId: restaurantId,
                name: dish.name,
                description: dish.description.isEmpty ? nil : dish.description,
                price: dish.price > 0 ? dish.price : nil,
                category: dish.category,
                dietaryTags: dish.dietaryTags.isEmpty ? nil : dish.dietaryTags,
                submittedBy: userId
            )
            
            do {
                let saved: SupabaseDish = try await client
                    .from("dishes")
                    .insert(newDish)
                    .select()
                    .single()
                    .execute()
                    .value
                
                savedDishes.append(saved)
            } catch {
                print("Error saving dish \(dish.name): \(error)")
                // Continue saving other dishes even if one fails
            }
        }
        
        // Update extraction status to approved
        do {
            try await client
                .from("menu_extractions")
                .update([
                    "status": "approved",
                    "approved_at": Date().ISO8601Format(),
                    "approved_by": userId.uuidString
                ])
                .eq("id", value: extractionId.uuidString)
                .execute()
        } catch {
            print("Error updating extraction status: \(error)")
        }
        
        return savedDishes
    }
    
    /// Check for duplicate dish names in a restaurant
    func checkDuplicateDishes(restaurantId: UUID, dishNames: [String]) async throws -> [String: Bool] {
        do {
            let existingDishes: [SupabaseDish] = try await client
                .from("dishes")
                .select()
                .eq("restaurant_id", value: restaurantId.uuidString)
                .execute()
                .value
            
            let existingNames = Set(existingDishes.map { $0.name.lowercased() })
            
            var duplicates: [String: Bool] = [:]
            for name in dishNames {
                duplicates[name] = existingNames.contains(name.lowercased())
            }
            
            return duplicates
        } catch {
            throw SupabaseServiceError.networkError(error)
        }
    }
}

// MARK: - Model Converters

extension SupabaseRestaurant {
    /// Convert Supabase restaurant to app's Restaurant model
    func toRestaurant() -> Restaurant {
        // Try to parse cuisine from database, or infer from name/categories
        let cuisineType: CuisineType = {
            if let cuisine = self.cuisineType, !cuisine.isEmpty,
               let type = CuisineType(rawValue: cuisine) {
                return type
            }
            // Infer from restaurant name as fallback
            let nameLower = self.name.lowercased()
            if nameLower.contains("pizza") || nameLower.contains("pizzeria") {
                return .pizza
            } else if nameLower.contains("pasta") || nameLower.contains("italian") || nameLower.contains("trattoria") || nameLower.contains("ristorante") {
                return .pasta
            } else if nameLower.contains("sushi") || nameLower.contains("sashimi") {
                return .sushi
            } else if nameLower.contains("ramen") || nameLower.contains("noodle house") {
                return .ramen
            } else if nameLower.contains("cafe") || nameLower.contains("café") || nameLower.contains("coffee") {
                return .cafe
            } else if nameLower.contains("taco") || nameLower.contains("taqueria") || nameLower.contains("burrito") {
                return .tacos
            } else if nameLower.contains("burger") {
                return .burgers
            } else if nameLower.contains("bbq") || nameLower.contains("barbecue") || nameLower.contains("smokehouse") {
                return .bbq
            } else if nameLower.contains("thai") || nameLower.contains("pad") {
                return .thai
            } else if nameLower.contains("indian") || nameLower.contains("curry") || nameLower.contains("tandoor") {
                return .indian
            } else if nameLower.contains("mediterranean") || nameLower.contains("greek") || nameLower.contains("falafel") {
                return .mediterranean
            } else if nameLower.contains("chinese") || nameLower.contains("dim sum") || nameLower.contains("wok") {
                return .chinese
            } else if nameLower.contains("seafood") || nameLower.contains("oyster") || nameLower.contains("crab") {
                return .seafood
            } else if nameLower.contains("steak") || nameLower.contains("steakhouse") || nameLower.contains("grill") {
                return .steakhouse
            } else if nameLower.contains("bakery") || nameLower.contains("pastry") || nameLower.contains("patisserie") {
                return .bakery
            }
            return .burgers
        }()
        
        return Restaurant(
            id: self.id,
            name: self.name,
            cuisine: cuisineType,
            description: "", // Not in Supabase schema
            address: self.formattedAddress ?? self.address ?? "",
            coordinate: Coordinate(
                latitude: self.latitude ?? 0,
                longitude: self.longitude ?? 0
            ),
            priceRange: .moderate, // Not in Supabase schema yet
            imageEmoji: cuisineType.emoji,
            headerColor: cuisineType.rawValue.lowercased(),
            dishes: self.dishes?.map { $0.toDish() } ?? [],
            isFeatured: false // Not in Supabase schema yet
        )
    }
}

extension SupabaseDish {
    /// Convert Supabase dish to app's Dish model
    func toDish() -> Dish {
        let category = DishCategory(rawValue: self.category ?? "") ?? .main
        let tags = self.dietaryTags ?? []
        
        return Dish(
            id: self.id,
            name: self.name,
            description: self.description ?? "",
            price: self.price ?? 0,
            category: category,
            imageEmoji: category.emoji,
            imageName: nil, // Use photoUrl instead
            isPopular: (self.ratingCount ?? 0) > 10,
            isSpicy: false,
            isVegetarian: tags.contains("vegetarian"),
            isVegan: tags.contains("vegan"),
            isGlutenFree: tags.contains("gluten-free"),
            ratings: self.ratings?.map { $0.toDishRating() } ?? []
        )
    }
}

extension SupabaseRating {
    /// Convert Supabase rating to app's DishRating model
    func toDishRating() -> DishRating {
        return DishRating(
            id: self.id,
            dishId: self.dishId,
            userId: self.userId,
            userName: self.profile?.fullName ?? self.profile?.username ?? "Anonymous",
            userEmoji: self.profile?.avatarEmoji ?? "🧑",
            userAvatarImageName: nil,
            rating: Double(self.rating),
            comment: self.comment ?? "",
            date: self.createdAt ?? Date(),
            helpful: self.helpfulCount ?? 0,
            photos: self.photos?.map { $0.photoUrl } ?? []
        )
    }
}

extension SupabaseProfile {
    /// Convert Supabase profile to app's User model
    func toUser() -> User {
        return User(
            id: self.id,
            username: self.username ?? "",
            email: "", // Email not stored in profiles
            fullName: self.fullName ?? "",
            avatarEmoji: self.avatarEmoji ?? "🧑",
            avatarImageName: nil,
            profileImageData: nil,
            bio: self.bio ?? "",
            joinDate: self.createdAt ?? Date(),
            ratingsCount: 0, // Would need to query
            favoriteRestaurants: []
        )
    }
}
