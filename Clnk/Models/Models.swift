import Foundation
import SwiftUI
import CoreLocation

// MARK: - User Model
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var email: String
    var fullName: String
    var avatarEmoji: String
    var avatarImageName: String? // Name of profile image asset in Assets.xcassets
    var profileImageData: Data? // Custom profile image data (from camera/photo library)
    var bio: String // User's bio/about text
    var joinDate: Date
    var ratingsCount: Int
    var favoriteRestaurants: [UUID]
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    // Coding keys for backward compatibility
    enum CodingKeys: String, CodingKey {
        case id, username, email, fullName, avatarEmoji, avatarImageName, profileImageData, bio, joinDate, ratingsCount, favoriteRestaurants
    }
    
    init(id: UUID, username: String, email: String, fullName: String, avatarEmoji: String, avatarImageName: String? = nil, profileImageData: Data? = nil, bio: String = "", joinDate: Date, ratingsCount: Int, favoriteRestaurants: [UUID]) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.avatarEmoji = avatarEmoji
        self.avatarImageName = avatarImageName
        self.profileImageData = profileImageData
        self.bio = bio
        self.joinDate = joinDate
        self.ratingsCount = ratingsCount
        self.favoriteRestaurants = favoriteRestaurants
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        fullName = try container.decode(String.self, forKey: .fullName)
        avatarEmoji = try container.decode(String.self, forKey: .avatarEmoji)
        avatarImageName = try container.decodeIfPresent(String.self, forKey: .avatarImageName)
        profileImageData = try container.decodeIfPresent(Data.self, forKey: .profileImageData)
        bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        joinDate = try container.decode(Date.self, forKey: .joinDate)
        ratingsCount = try container.decode(Int.self, forKey: .ratingsCount)
        favoriteRestaurants = try container.decode([UUID].self, forKey: .favoriteRestaurants)
    }
}

// MARK: - Coordinate Model (for Codable support)
struct Coordinate: Codable, Equatable, Hashable {
    let latitude: Double
    let longitude: Double
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

// MARK: - Restaurant Model
struct Restaurant: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var cuisine: CuisineType
    var description: String
    var address: String
    var coordinate: Coordinate
    var priceRange: PriceRange
    var imageEmoji: String
    var headerColor: String
    var dishes: [Dish]
    var isFeatured: Bool
    
    /// Convenience accessor for CLLocationCoordinate2D
    var locationCoordinate: CLLocationCoordinate2D {
        coordinate.clLocationCoordinate2D
    }
    
    var averageRating: Double {
        let allRatings = dishes.flatMap { $0.ratings }
        guard !allRatings.isEmpty else { return 0 }
        return allRatings.reduce(0.0) { $0 + $1.rating } / Double(allRatings.count)
    }
    
    var totalRatings: Int {
        dishes.reduce(0) { $0 + $1.ratings.count }
    }
    
    var topDishes: [Dish] {
        dishes.filter { !$0.ratings.isEmpty }
            .sorted { $0.averageRating > $1.averageRating }
            .prefix(3)
            .map { $0 }
    }
}

// MARK: - Dish Model
struct Dish: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var price: Double
    var category: DishCategory
    var imageEmoji: String
    var imageName: String? // Name of image asset in Assets.xcassets
    var imageData: Data? // Custom image data from camera/photo library
    var isPopular: Bool
    var isSpicy: Bool
    var isVegetarian: Bool
    var isVegan: Bool
    var isGlutenFree: Bool
    var ratings: [DishRating]
    
    var averageRating: Double {
        guard !ratings.isEmpty else { return 0 }
        return ratings.reduce(0.0) { $0 + $1.rating } / Double(ratings.count)
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    // Convenience initializer for backward compatibility
    init(id: UUID, name: String, description: String, price: Double, category: DishCategory,
         imageEmoji: String, imageName: String? = nil, imageData: Data? = nil, isPopular: Bool, isSpicy: Bool, isVegetarian: Bool,
         isVegan: Bool = false, isGlutenFree: Bool = false, ratings: [DishRating]) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.imageEmoji = imageEmoji
        self.imageName = imageName
        self.imageData = imageData
        self.isPopular = isPopular
        self.isSpicy = isSpicy
        self.isVegetarian = isVegetarian
        self.isVegan = isVegan
        self.isGlutenFree = isGlutenFree
        self.ratings = ratings
    }
}

// MARK: - Rating Model
struct DishRating: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let dishId: UUID
    let userId: UUID
    let userName: String
    let userEmoji: String
    var userAvatarImageName: String? // Name of profile image asset
    var rating: Double // 1-5 simple star rating
    var comment: String
    var date: Date
    var helpful: Int
    var photos: [String] // photo identifiers/emojis
    var sweet: Double?   // 0.0 to 1.0
    var salty: Double?
    var bitter: Double?
    var sour: Double?
}

// MARK: - Enums
enum CuisineType: String, Codable, CaseIterable {
    case classic = "Classic"
    case whiskey = "Whiskey"
    case tiki = "Tiki"
    case wine = "Wine"
    case dive = "Dive Bar"
    case gin = "Gin"
    case modern = "Modern"
    case tequila = "Tequila"

    var emoji: String {
        switch self {
        case .classic: return "🥃"
        case .whiskey: return "🥃"
        case .tiki: return "🍹"
        case .wine: return "🍷"
        case .dive: return "🍺"
        case .gin: return "🍸"
        case .modern: return "🧪"
        case .tequila: return "🌵"
        }
    }

    var accentColor: Color {
        switch self {
        case .classic: return Color(red: 0.55, green: 0.27, blue: 0.07)
        case .whiskey: return Color(red: 0.72, green: 0.45, blue: 0.20)
        case .tiki: return Color(red: 0.01, green: 0.33, blue: 0.32)
        case .wine: return Color(red: 0.45, green: 0.18, blue: 0.22)
        case .dive: return Color(red: 0.80, green: 0.52, blue: 0.25)
        case .gin: return Color(red: 0.13, green: 0.55, blue: 0.13)
        case .modern: return Color(red: 0.58, green: 0.0, blue: 0.83)
        case .tequila: return Color(red: 0.85, green: 0.65, blue: 0.13)
        }
    }
}

enum PriceRange: Int, Codable, CaseIterable {
    case budget = 1
    case moderate = 2
    case upscale = 3
    case fine = 4
    
    var display: String {
        String(repeating: "$", count: rawValue)
    }
    
    var description: String {
        switch self {
        case .budget: return "Budget-friendly"
        case .moderate: return "Moderate"
        case .upscale: return "Upscale"
        case .fine: return "Premium"
        }
    }
}

enum DishCategory: String, Codable, CaseIterable {
    case classic = "Classic"
    case signature = "Signature"
    case tiki = "Tiki"
    case seasonal = "Seasonal"
    case whiskey = "Whiskey"
    case modern = "Modern"

    var emoji: String {
        switch self {
        case .classic: return "🥃"
        case .signature: return "✨"
        case .tiki: return "🍹"
        case .seasonal: return "🌸"
        case .whiskey: return "🥃"
        case .modern: return "🧪"
        }
    }

    var sortOrder: Int {
        switch self {
        case .classic: return 0
        case .signature: return 1
        case .tiki: return 2
        case .seasonal: return 3
        case .whiskey: return 4
        case .modern: return 5
        }
    }
}

// MARK: - Drink Filter Options
enum DietaryFilter: String, CaseIterable {
    case nonAlcoholic = "Non-Alcoholic"
    case stirred = "Stirred"
    case shaken = "Shaken"

    var emoji: String {
        switch self {
        case .nonAlcoholic: return "🌿"
        case .stirred: return "🥄"
        case .shaken: return "🧊"
        }
    }
}

// MARK: - User Follow Model
struct UserFollow: Identifiable, Codable, Equatable {
    let id: UUID
    let followerId: UUID    // The user who is following
    let followingId: UUID   // The user being followed
    let createdAt: Date
    
    init(id: UUID = UUID(), followerId: UUID, followingId: UUID, createdAt: Date = Date()) {
        self.id = id
        self.followerId = followerId
        self.followingId = followingId
        self.createdAt = createdAt
    }
}

// MARK: - Follow User Info (for display)
struct FollowUserInfo: Identifiable, Equatable {
    let id: UUID
    let username: String
    let fullName: String
    let avatarEmoji: String
    let avatarImageName: String?
    let bio: String?
    let followedAt: Date
}
