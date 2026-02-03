import Foundation

/// AI-powered recommendation engine that analyzes user rating patterns
/// to suggest dishes they'll likely enjoy
struct RecommendationEngine {
    
    // MARK: - Constants
    
    /// Minimum ratings needed before generating recommendations
    static let minimumRatingsThreshold = 5
    
    /// Weight for different factors in scoring
    private static let cuisineWeight = 0.25
    private static let priceWeight = 0.15
    private static let categoryWeight = 0.20
    private static let dietaryWeight = 0.20
    private static let popularityWeight = 0.20
    
    // MARK: - User Preference Profile
    
    struct UserPreferenceProfile {
        let favoriteCuisines: [CuisineType: Double] // cuisine -> preference score
        let preferredPriceRange: PriceRange?
        let favoriteDishCategories: [DishCategory: Double]
        let dietaryPreferences: DietaryPreferences
        let averageRatingGiven: Double
        let highlyRatedDishes: [Dish] // dishes rated 4+ stars
    }
    
    struct DietaryPreferences {
        let vegetarian: Bool
        let vegan: Bool
        let glutenFree: Bool
        let avoidsSpicy: Bool
    }
    
    // MARK: - Public Methods
    
    /// Check if user has enough ratings to generate recommendations
    static func hasEnoughRatings(userRatings: [DishRating]) -> Bool {
        return userRatings.count >= minimumRatingsThreshold
    }
    
    /// Generate personalized dish recommendations based on user's rating history
    /// - Parameters:
    ///   - userRatings: All ratings from the current user
    ///   - allRestaurants: Complete list of restaurants with their dishes
    ///   - limit: Maximum number of recommendations to return
    /// - Returns: Array of recommended dishes with their restaurants, sorted by recommendation score
    static func generateRecommendations(
        userRatings: [UUID: DishRating],
        allRestaurants: [Restaurant],
        limit: Int = 10
    ) -> [(dish: Dish, restaurant: Restaurant, score: Double)] {
        
        // Build user preference profile
        let profile = buildUserProfile(from: Array(userRatings.values), allRestaurants: allRestaurants)
        
        // Get all dishes the user hasn't rated yet
        let ratedDishIds = Set(userRatings.keys)
        var candidates: [(dish: Dish, restaurant: Restaurant)] = []
        
        for restaurant in allRestaurants {
            for dish in restaurant.dishes {
                if !ratedDishIds.contains(dish.id) {
                    candidates.append((dish, restaurant))
                }
            }
        }
        
        // Score each candidate
        let scoredCandidates = candidates.map { candidate -> (dish: Dish, restaurant: Restaurant, score: Double) in
            let score = calculateRecommendationScore(
                dish: candidate.dish,
                restaurant: candidate.restaurant,
                profile: profile
            )
            return (candidate.dish, candidate.restaurant, score)
        }
        
        // Sort by score and return top N
        return scoredCandidates
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Private Helpers
    
    /// Build a comprehensive profile of user preferences from their rating history
    private static func buildUserProfile(
        from ratings: [DishRating],
        allRestaurants: [Restaurant]
    ) -> UserPreferenceProfile {
        
        // Find dishes user has rated highly (4+ stars)
        let highRatings = ratings.filter { $0.rating >= 4.0 }
        
        // Extract the actual dish objects
        var highlyRatedDishes: [Dish] = []
        for rating in highRatings {
            if let dish = findDish(id: rating.dishId, in: allRestaurants) {
                highlyRatedDishes.append(dish.dish)
            }
        }
        
        // Analyze cuisine preferences
        var cuisineScores: [CuisineType: Double] = [:]
        for rating in highRatings {
            if let result = findDish(id: rating.dishId, in: allRestaurants) {
                let cuisine = result.restaurant.cuisine
                cuisineScores[cuisine, default: 0] += rating.rating
            }
        }
        // Normalize cuisine scores
        let totalCuisineScore = cuisineScores.values.reduce(0, +)
        if totalCuisineScore > 0 {
            for cuisine in cuisineScores.keys {
                cuisineScores[cuisine]! /= totalCuisineScore
            }
        }
        
        // Analyze price range preference (most common in high ratings)
        var priceFrequency: [PriceRange: Int] = [:]
        for rating in highRatings {
            if let result = findDish(id: rating.dishId, in: allRestaurants) {
                priceFrequency[result.restaurant.priceRange, default: 0] += 1
            }
        }
        let preferredPriceRange = priceFrequency.max(by: { $0.value < $1.value })?.key
        
        // Analyze dish category preferences
        var categoryScores: [DishCategory: Double] = [:]
        for rating in highRatings {
            if let dish = findDish(id: rating.dishId, in: allRestaurants)?.dish {
                categoryScores[dish.category, default: 0] += rating.rating
            }
        }
        // Normalize category scores
        let totalCategoryScore = categoryScores.values.reduce(0, +)
        if totalCategoryScore > 0 {
            for category in categoryScores.keys {
                categoryScores[category]! /= totalCategoryScore
            }
        }
        
        // Analyze dietary preferences
        let vegetarianCount = highlyRatedDishes.filter { $0.isVegetarian }.count
        let veganCount = highlyRatedDishes.filter { $0.isVegan }.count
        let glutenFreeCount = highlyRatedDishes.filter { $0.isGlutenFree }.count
        let nonSpicyCount = highlyRatedDishes.filter { !$0.isSpicy }.count
        
        let dietaryPreferences = DietaryPreferences(
            vegetarian: Double(vegetarianCount) / Double(max(1, highlyRatedDishes.count)) > 0.6,
            vegan: Double(veganCount) / Double(max(1, highlyRatedDishes.count)) > 0.6,
            glutenFree: Double(glutenFreeCount) / Double(max(1, highlyRatedDishes.count)) > 0.6,
            avoidsSpicy: Double(nonSpicyCount) / Double(max(1, highlyRatedDishes.count)) > 0.7
        )
        
        // Calculate average rating
        let averageRating = ratings.isEmpty ? 3.0 : ratings.reduce(0.0) { $0 + $1.rating } / Double(ratings.count)
        
        return UserPreferenceProfile(
            favoriteCuisines: cuisineScores,
            preferredPriceRange: preferredPriceRange,
            favoriteDishCategories: categoryScores,
            dietaryPreferences: dietaryPreferences,
            averageRatingGiven: averageRating,
            highlyRatedDishes: highlyRatedDishes
        )
    }
    
    /// Calculate recommendation score for a dish based on user profile
    private static func calculateRecommendationScore(
        dish: Dish,
        restaurant: Restaurant,
        profile: UserPreferenceProfile
    ) -> Double {
        var score = 0.0
        
        // 1. Cuisine preference match
        let cuisineScore = profile.favoriteCuisines[restaurant.cuisine] ?? 0.1
        score += cuisineScore * cuisineWeight
        
        // 2. Price range match
        if let preferredPrice = profile.preferredPriceRange {
            let priceDiff = abs(restaurant.priceRange.rawValue - preferredPrice.rawValue)
            let priceScore = max(0, 1.0 - (Double(priceDiff) * 0.3))
            score += priceScore * priceWeight
        } else {
            score += 0.5 * priceWeight // neutral score if no preference
        }
        
        // 3. Dish category match
        let categoryScore = profile.favoriteDishCategories[dish.category] ?? 0.1
        score += categoryScore * categoryWeight
        
        // 4. Dietary preferences match
        var dietaryScore = 1.0
        if profile.dietaryPreferences.vegetarian && !dish.isVegetarian {
            dietaryScore -= 0.5
        }
        if profile.dietaryPreferences.vegan && !dish.isVegan {
            dietaryScore -= 0.5
        }
        if profile.dietaryPreferences.glutenFree && !dish.isGlutenFree {
            dietaryScore -= 0.3
        }
        if profile.dietaryPreferences.avoidsSpicy && dish.isSpicy {
            dietaryScore -= 0.4
        }
        score += max(0, dietaryScore) * dietaryWeight
        
        // 5. Popularity and rating (collective intelligence)
        if dish.ratings.count >= 3 {
            let popularityScore = min(1.0, dish.averageRating / 5.0)
            score += popularityScore * popularityWeight
        } else {
            // New dishes with few ratings get a moderate boost (exploration)
            score += 0.5 * popularityWeight
        }
        
        // Boost for dishes with characteristics similar to highly-rated dishes
        let similarityBoost = calculateSimilarityBoost(dish: dish, profile: profile)
        score += similarityBoost * 0.15
        
        return min(1.0, score) // Normalize to 0-1 range
    }
    
    /// Calculate similarity boost based on flavor profile and characteristics
    private static func calculateSimilarityBoost(dish: Dish, profile: UserPreferenceProfile) -> Double {
        var boost = 0.0
        
        for favoriteDish in profile.highlyRatedDishes {
            // Same category
            if dish.category == favoriteDish.category {
                boost += 0.2
            }
            
            // Similar dietary attributes
            if dish.isVegetarian == favoriteDish.isVegetarian {
                boost += 0.1
            }
            if dish.isSpicy == favoriteDish.isSpicy {
                boost += 0.1
            }
            
            // Similar price range (within $5)
            if abs(dish.price - favoriteDish.price) <= 5.0 {
                boost += 0.1
            }
        }
        
        return min(1.0, boost / Double(max(1, profile.highlyRatedDishes.count)))
    }
    
    /// Find a dish and its restaurant by ID
    private static func findDish(
        id: UUID,
        in restaurants: [Restaurant]
    ) -> (dish: Dish, restaurant: Restaurant)? {
        for restaurant in restaurants {
            if let dish = restaurant.dishes.first(where: { $0.id == id }) {
                return (dish, restaurant)
            }
        }
        return nil
    }
}
