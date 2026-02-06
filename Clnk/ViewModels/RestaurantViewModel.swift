import Foundation
import SwiftUI
import CoreLocation

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var searchText = ""
    @Published var selectedCuisine: CuisineType?
    @Published var userRatings: [UUID: DishRating] = [:] // dishId -> user's rating
    @Published var favoriteRestaurants: Set<UUID> = []
    @Published var markedHelpfulReviews: Set<UUID> = [] // ratingIds marked helpful by current user
    @Published var blockedUserIds: Set<UUID> = [] // UGC: blocked users
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // AI Recommendations
    @Published var recommendations: [(Dish, Restaurant, Double)] = []
    @Published var showRecommendations = false
    
    // Pagination for All Restaurants
    @Published var restaurantsPageSize: Int = 20
    @Published var restaurantsDisplayCount: Int = 20
    
    // Supabase service
    private let service = SupabaseService.shared
    
    // UserDefaults key for persisting helpful reviews (local cache)
    private let helpfulReviewsKey = "markedHelpfulReviews"
    // UserDefaults key for persisting blocked users (local cache)
    private let blockedUsersKey = "blockedUserIds"
    
    // Use MockData as fallback when Supabase is unavailable
    private var useMockDataFallback = false
    
    // Force demo mode (use MockData only)
    var forceDemoMode = false
    
    // MARK: - Switch to Demo Mode
    func switchToDemoMode() {
        forceDemoMode = true
        self.restaurants = MockData.restaurants
        self.useMockDataFallback = true
        
        // Load demo following data
        followingIds = MockData.demoFollowingUserIds
        followingUsers = MockData.demoFollowingUsers
        saveFollowing()
    }
    
    // Location-based properties
    private var locationManager: LocationManager?
    
    init() {
        loadHelpfulReviews()
        loadBlockedUsers()
        loadRestaurants()
    }
    
    // MARK: - Helpful Reviews Persistence
    private func loadHelpfulReviews() {
        if let data = UserDefaults.standard.data(forKey: helpfulReviewsKey),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            markedHelpfulReviews = ids
        }
    }
    
    private func saveHelpfulReviews() {
        if let data = try? JSONEncoder().encode(markedHelpfulReviews) {
            UserDefaults.standard.set(data, forKey: helpfulReviewsKey)
        }
    }
    
    // MARK: - Blocked Users Persistence (UGC Compliance)
    private func loadBlockedUsers() {
        if let data = UserDefaults.standard.data(forKey: blockedUsersKey),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            blockedUserIds = ids
        }
    }
    
    private func saveBlockedUsers() {
        if let data = try? JSONEncoder().encode(blockedUserIds) {
            UserDefaults.standard.set(data, forKey: blockedUsersKey)
        }
    }
    
    // MARK: - Toggle Helpful
    func toggleHelpful(for ratingId: UUID) {
        // Optimistic update
        if markedHelpfulReviews.contains(ratingId) {
            markedHelpfulReviews.remove(ratingId)
            updateHelpfulCount(for: ratingId, increment: false)
        } else {
            markedHelpfulReviews.insert(ratingId)
            updateHelpfulCount(for: ratingId, increment: true)
        }
        saveHelpfulReviews()
        
        // Sync with Supabase (don't await, fire-and-forget with error handling)
        Task {
            do {
                _ = try await service.toggleHelpful(ratingId: ratingId)
            } catch SupabaseServiceError.notAuthenticated {
                // User not logged in - keep local state
                print("Helpful vote saved locally - user not authenticated")
            } catch {
                print("Failed to sync helpful vote: \(error)")
                // Revert on failure? For now keep local state
            }
        }
    }
    
    // MARK: - Check if Marked Helpful
    func isMarkedHelpful(_ ratingId: UUID) -> Bool {
        markedHelpfulReviews.contains(ratingId)
    }
    
    // MARK: - Update Helpful Count in Data
    private func updateHelpfulCount(for ratingId: UUID, increment: Bool) {
        for restaurantIndex in restaurants.indices {
            for dishIndex in restaurants[restaurantIndex].dishes.indices {
                if let ratingIndex = restaurants[restaurantIndex].dishes[dishIndex].ratings.firstIndex(where: { $0.id == ratingId }) {
                    if increment {
                        restaurants[restaurantIndex].dishes[dishIndex].ratings[ratingIndex].helpful += 1
                    } else {
                        restaurants[restaurantIndex].dishes[dishIndex].ratings[ratingIndex].helpful = max(0, restaurants[restaurantIndex].dishes[dishIndex].ratings[ratingIndex].helpful - 1)
                    }
                    return
                }
            }
        }
    }
    
    // MARK: - Get Helpful Count for a Rating
    func helpfulCount(for ratingId: UUID) -> Int {
        for restaurant in restaurants {
            for dish in restaurant.dishes {
                if let rating = dish.ratings.first(where: { $0.id == ratingId }) {
                    return rating.helpful
                }
            }
        }
        return 0
    }
    
    // MARK: - Location Manager Binding
    func bindLocationManager(_ manager: LocationManager) {
        self.locationManager = manager
    }
    
    // MARK: - Load Data
    func loadRestaurants() {
        isLoading = true
        errorMessage = nil
        
        // If demo mode, use MockData directly
        if forceDemoMode {
            self.restaurants = MockData.restaurants
            self.useMockDataFallback = true
            self.isLoading = false
            return
        }
        
        Task {
            do {
                // Fetch from Supabase
                let supabaseRestaurants = try await service.fetchAllRestaurants()
                
                // Convert to app models
                var appRestaurants: [Restaurant] = []
                for sbRestaurant in supabaseRestaurants {
                    // Fetch dishes for each restaurant
                    let dishes = try await service.fetchDishes(restaurantId: sbRestaurant.id)
                    var restaurant = sbRestaurant.toRestaurant()
                    restaurant.dishes = dishes.map { $0.toDish() }
                    appRestaurants.append(restaurant)
                }
                
                self.restaurants = appRestaurants
                self.useMockDataFallback = false
                
                // Load favorites
                await loadFavorites()
                
                // Load helpful votes
                await loadHelpfulVotes()
                
            } catch {
                print("Failed to load from Supabase: \(error)")
                errorMessage = "Could not connect to server. Showing demo data."
                
                // Fall back to MockData
                self.restaurants = MockData.restaurants
                self.useMockDataFallback = true
            }
            
            self.isLoading = false
        }
    }
    
    // MARK: - Refresh Data
    func refreshRestaurants() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let supabaseRestaurants = try await service.fetchAllRestaurants()
            
            var appRestaurants: [Restaurant] = []
            for sbRestaurant in supabaseRestaurants {
                let dishes = try await service.fetchDishes(restaurantId: sbRestaurant.id)
                var restaurant = sbRestaurant.toRestaurant()
                restaurant.dishes = dishes.map { $0.toDish() }
                appRestaurants.append(restaurant)
            }
            
            self.restaurants = appRestaurants
            self.useMockDataFallback = false
            
            await loadFavorites()
            await loadHelpfulVotes()
            
        } catch {
            print("Failed to refresh: \(error)")
            errorMessage = "Could not refresh data"
        }
        
        isLoading = false
    }
    
    // MARK: - Load Favorites from Supabase
    private func loadFavorites() async {
        do {
            let favorites = try await service.fetchFavorites()
            favoriteRestaurants = Set(favorites.map { $0.restaurantId })
        } catch SupabaseServiceError.notAuthenticated {
            // User not logged in - use local state
            print("User not authenticated, using local favorites")
        } catch {
            print("Failed to load favorites: \(error)")
        }
    }
    
    // MARK: - Load Helpful Votes from Supabase
    private func loadHelpfulVotes() async {
        do {
            let votes = try await service.fetchHelpfulVotes()
            markedHelpfulReviews = Set(votes.map { $0.ratingId })
            saveHelpfulReviews() // Sync to local
        } catch SupabaseServiceError.notAuthenticated {
            // User not logged in - use local state
            print("User not authenticated, using local helpful votes")
        } catch {
            print("Failed to load helpful votes: \(error)")
        }
    }
    
    // MARK: - Filtered Restaurants (sorted by proximity, paginated)
    var filteredRestaurants: [Restaurant] {
        var result = restaurants
        
        // Filter by cuisine
        if let cuisine = selectedCuisine {
            result = result.filter { $0.cuisine == cuisine }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            result = result.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.cuisine.rawValue.localizedCaseInsensitiveContains(searchText) ||
                restaurant.dishes.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort by proximity
        result = result.sorted { restaurant1, restaurant2 in
            let distance1 = distance(to: restaurant1) ?? Double.infinity
            let distance2 = distance(to: restaurant2) ?? Double.infinity
            return distance1 < distance2
        }
        
        return result
    }
    
    // MARK: - Paginated Restaurants
    var paginatedRestaurants: [Restaurant] {
        Array(filteredRestaurants.prefix(restaurantsDisplayCount))
    }
    
    var hasMoreRestaurants: Bool {
        restaurantsDisplayCount < filteredRestaurants.count
    }
    
    func loadMoreRestaurants() {
        restaurantsDisplayCount += restaurantsPageSize
    }
    
    func resetRestaurantsPagination() {
        restaurantsDisplayCount = restaurantsPageSize
    }
    
    // MARK: - Nearby Restaurants (Location-Based)
    var nearbyRestaurants: [Restaurant] {
        guard let manager = locationManager,
              manager.effectiveSearchLocation != nil else {
            return restaurants
        }
        
        return restaurants.filter { restaurant in
            manager.isWithinSearchRadius(restaurant.locationCoordinate)
        }.sorted { restaurant1, restaurant2 in
            let distance1 = distance(to: restaurant1) ?? Double.infinity
            let distance2 = distance(to: restaurant2) ?? Double.infinity
            return distance1 < distance2
        }
    }
    
    // MARK: - Distance to Restaurant
    func distance(to restaurant: Restaurant) -> Double? {
        locationManager?.distanceFromSearchCenter(to: restaurant.locationCoordinate)
    }
    
    // MARK: - Formatted Distance
    func formattedDistance(to restaurant: Restaurant) -> String? {
        guard let miles = distance(to: restaurant) else { return nil }
        let feet = Int(miles * 5280)
        if feet < 1000 {
            return "\(feet) ft"
        } else {
            // Show as X.X mi for distances >= 1000 ft (roughly 0.19 mi)
            return String(format: "%.1f mi", miles)
        }
    }
    
    // MARK: - Featured Restaurants
    var featuredRestaurants: [Restaurant] {
        restaurants.filter { $0.isFeatured }
    }
    
    // MARK: - Top Rated Restaurants
    var topRatedRestaurants: [Restaurant] {
        restaurants.sorted { $0.averageRating > $1.averageRating }.prefix(5).map { $0 }
    }
    
    // MARK: - Get Restaurant
    func restaurant(withId id: UUID) -> Restaurant? {
        restaurants.first { $0.id == id }
    }
    
    // MARK: - Get Dish
    func dish(withId dishId: UUID, in restaurantId: UUID) -> Dish? {
        guard let restaurant = restaurant(withId: restaurantId) else { return nil }
        return restaurant.dishes.first { $0.id == dishId }
    }
    
    // MARK: - Dishes by Category
    func dishesByCategory(for restaurant: Restaurant) -> [(category: DishCategory, dishes: [Dish])] {
        let grouped = Dictionary(grouping: restaurant.dishes) { $0.category }
        return grouped.map { (category: $0.key, dishes: $0.value) }
            .sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    // MARK: - Submit Rating
    func submitRating(
        for dish: Dish,
        in restaurant: Restaurant,
        userId: UUID,
        userName: String,
        userEmoji: String,
        rating: Double,
        comment: String,
        photos: [String] = [],
        photoData: [Data]? = nil,
        sweet: Double? = nil,
        salty: Double? = nil,
        bitter: Double? = nil,
        sour: Double? = nil
    ) {
        // Create local rating immediately for responsiveness
        let newRating = DishRating(
            id: UUID(),
            dishId: dish.id,
            userId: userId,
            userName: userName,
            userEmoji: userEmoji,
            rating: rating,
            comment: comment,
            date: Date(),
            helpful: 0,
            photos: photos,
            sweet: sweet,
            salty: salty,
            bitter: bitter,
            sour: sour
        )
        
        // Store user's rating locally
        userRatings[dish.id] = newRating
        
        // Update the dish's ratings in our data
        if let restaurantIndex = restaurants.firstIndex(where: { $0.id == restaurant.id }),
           let dishIndex = restaurants[restaurantIndex].dishes.firstIndex(where: { $0.id == dish.id }) {
            restaurants[restaurantIndex].dishes[dishIndex].ratings.insert(newRating, at: 0)
        }
        
        // Submit to Supabase
        Task {
            do {
                let sbRating = try await service.submitRating(
                    dishId: dish.id,
                    rating: Int(rating),
                    comment: comment.isEmpty ? nil : comment,
                    photoData: photoData
                )
                
                // Update local rating with server ID
                var updatedRating = newRating
                updatedRating = DishRating(
                    id: sbRating.id,
                    dishId: dish.id,
                    userId: userId,
                    userName: userName,
                    userEmoji: userEmoji,
                    rating: rating,
                    comment: comment,
                    date: sbRating.createdAt ?? Date(),
                    helpful: 0,
                    photos: photos
                )
                userRatings[dish.id] = updatedRating
                
                print("Rating submitted successfully")
            } catch SupabaseServiceError.notAuthenticated {
                print("Rating saved locally - user not authenticated")
            } catch {
                print("Failed to submit rating to server: \(error)")
                // Keep local rating for offline support
            }
        }
    }
    
    // MARK: - Check if User Rated
    func userRating(for dishId: UUID) -> DishRating? {
        userRatings[dishId]
    }
    
    // MARK: - Update Rating
    func updateRating(
        ratingId: UUID,
        dishId: UUID,
        restaurantId: UUID,
        rating: Double,
        comment: String,
        photos: [String] = [],
        sweet: Double? = nil,
        salty: Double? = nil,
        bitter: Double? = nil,
        sour: Double? = nil
    ) {
        // Find and update the rating in userRatings
        if var existingRating = userRatings[dishId] {
            existingRating.rating = rating
            existingRating.comment = comment
            existingRating.photos = photos
            existingRating.sweet = sweet
            existingRating.salty = salty
            existingRating.bitter = bitter
            existingRating.sour = sour
            userRatings[dishId] = existingRating

            // Update the dish's ratings in our data
            if let restaurantIndex = restaurants.firstIndex(where: { $0.id == restaurantId }),
               let dishIndex = restaurants[restaurantIndex].dishes.firstIndex(where: { $0.id == dishId }),
               let ratingIndex = restaurants[restaurantIndex].dishes[dishIndex].ratings.firstIndex(where: { $0.id == ratingId }) {

                var updatedRating = restaurants[restaurantIndex].dishes[dishIndex].ratings[ratingIndex]
                updatedRating.rating = rating
                updatedRating.comment = comment
                updatedRating.photos = photos
                updatedRating.sweet = sweet
                updatedRating.salty = salty
                updatedRating.bitter = bitter
                updatedRating.sour = sour

                restaurants[restaurantIndex].dishes[dishIndex].ratings[ratingIndex] = updatedRating
            }
        }
        
        // Sync with Supabase
        Task {
            do {
                // Note: You'll need to implement updateRating in SupabaseService
                // For now, this is a placeholder for future implementation
                print("Rating updated successfully (local only)")
            } catch {
                print("Failed to update rating on server: \(error)")
            }
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ restaurantId: UUID) {
        // Optimistic update
        if favoriteRestaurants.contains(restaurantId) {
            favoriteRestaurants.remove(restaurantId)
        } else {
            favoriteRestaurants.insert(restaurantId)
        }
        
        // Sync with Supabase
        Task {
            do {
                _ = try await service.toggleFavorite(restaurantId: restaurantId)
            } catch SupabaseServiceError.notAuthenticated {
                print("Favorite saved locally - user not authenticated")
            } catch {
                print("Failed to sync favorite: \(error)")
                // Revert on failure
                if favoriteRestaurants.contains(restaurantId) {
                    favoriteRestaurants.remove(restaurantId)
                } else {
                    favoriteRestaurants.insert(restaurantId)
                }
            }
        }
    }
    
    // MARK: - Is Favorite
    func isFavorite(_ restaurantId: UUID) -> Bool {
        favoriteRestaurants.contains(restaurantId)
    }
    
    // MARK: - Add Dish
    func addDish(
        to restaurant: Restaurant,
        name: String,
        description: String? = nil,
        category: DishCategory? = nil,
        price: Double? = nil
    ) {
        Task {
            do {
                let sbDish = try await service.addDish(
                    restaurantId: restaurant.id,
                    name: name,
                    description: description,
                    category: category?.rawValue,
                    price: price
                )
                
                // Add to local data
                let dish = sbDish.toDish()
                if let restaurantIndex = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
                    restaurants[restaurantIndex].dishes.append(dish)
                }
                
                print("Dish added successfully")
            } catch SupabaseServiceError.notAuthenticated {
                errorMessage = "Please sign in to add dishes"
            } catch {
                errorMessage = "Failed to add dish: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Add Dish Locally (for demo mode)
    func addDishLocally(_ dish: Dish, to restaurantId: UUID) {
        if let restaurantIndex = restaurants.firstIndex(where: { $0.id == restaurantId }) {
            var updatedRestaurant = restaurants[restaurantIndex]
            updatedRestaurant.dishes.append(dish)
            restaurants[restaurantIndex] = updatedRestaurant
            
            // Force UI refresh by triggering objectWillChange
            objectWillChange.send()
        }
    }
    
    // MARK: - Search Suggestions
    var searchSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        
        var suggestions: Set<String> = []
        
        for restaurant in restaurants {
            if restaurant.name.localizedCaseInsensitiveContains(searchText) {
                suggestions.insert(restaurant.name)
            }
            if restaurant.cuisine.rawValue.localizedCaseInsensitiveContains(searchText) {
                suggestions.insert(restaurant.cuisine.rawValue)
            }
            for dish in restaurant.dishes {
                if dish.name.localizedCaseInsensitiveContains(searchText) {
                    suggestions.insert(dish.name)
                }
            }
        }
        
        return Array(suggestions).prefix(5).map { $0 }
    }
    
    // MARK: - Popular Dishes Across All Restaurants
    var trendingDishes: [(dish: Dish, restaurant: Restaurant)] {
        var allDishes: [(dish: Dish, restaurant: Restaurant)] = []
        
        for restaurant in restaurants {
            for dish in restaurant.dishes where dish.isPopular {
                allDishes.append((dish, restaurant))
            }
        }
        
        return allDishes.sorted { $0.dish.averageRating > $1.dish.averageRating }.prefix(10).map { $0 }
    }
    
    // MARK: - Top Rated Dishes Across All Restaurants
    var topRatedDishes: [(dish: Dish, restaurant: Restaurant)] {
        var allDishes: [(dish: Dish, restaurant: Restaurant)] = []
        
        for restaurant in restaurants {
            for dish in restaurant.dishes where !dish.ratings.isEmpty {
                allDishes.append((dish, restaurant))
            }
        }
        
        return allDishes.sorted { $0.dish.averageRating > $1.dish.averageRating }.prefix(5).map { $0 }
    }
    
    // MARK: - Recent Ratings (mock)
    var recentActivity: [DishRating] {
        var allRatings: [DishRating] = []
        
        for restaurant in restaurants {
            for dish in restaurant.dishes {
                allRatings.append(contentsOf: dish.ratings.prefix(2))
            }
        }
        
        return allRatings.sorted { $0.date > $1.date }.prefix(20).map { $0 }
    }
    
    // MARK: - AI Recommendations
    
    /// Check if user has enough ratings to show recommendations
    var hasEnoughRatingsForRecommendations: Bool {
        return userRatings.count >= RecommendationEngine.minimumRatingsThreshold
    }
    
    /// Update recommendations based on user's rating history
    func updateRecommendations() {
        guard hasEnoughRatingsForRecommendations else {
            recommendations = []
            showRecommendations = false
            return
        }
        
        recommendations = RecommendationEngine.generateRecommendations(
            userRatings: userRatings,
            allRestaurants: restaurants,
            limit: 10
        )
        
        showRecommendations = !recommendations.isEmpty
    }
    
    /// Dismiss recommendations section
    func dismissRecommendations() {
        showRecommendations = false
    }
    
    // MARK: - UGC Compliance: Block User
    func blockUser(_ userId: UUID) {
        blockedUserIds.insert(userId)
        saveBlockedUsers()
        
        // Sync with Supabase
        Task {
            do {
                _ = try await service.blockUser(userId: userId)
                print("User blocked successfully")
            } catch SupabaseServiceError.notAuthenticated {
                print("Block saved locally - user not authenticated")
            } catch {
                print("Failed to sync block: \(error)")
            }
        }
        
        // Force UI update
        objectWillChange.send()
    }
    
    // MARK: - UGC Compliance: Unblock User
    func unblockUser(_ userId: UUID) {
        blockedUserIds.remove(userId)
        saveBlockedUsers()
        
        // Sync with Supabase
        Task {
            do {
                _ = try await service.unblockUser(userId: userId)
                print("User unblocked successfully")
            } catch SupabaseServiceError.notAuthenticated {
                print("Unblock saved locally - user not authenticated")
            } catch {
                print("Failed to sync unblock: \(error)")
            }
        }
        
        // Force UI update
        objectWillChange.send()
    }
    
    // MARK: - UGC Compliance: Check if User is Blocked
    func isUserBlocked(_ userId: UUID) -> Bool {
        blockedUserIds.contains(userId)
    }
    
    // MARK: - UGC Compliance: Report Review
    func reportReview(ratingId: UUID, reason: String, details: String?) {
        // Submit to Supabase
        Task {
            do {
                _ = try await service.reportReview(
                    ratingId: ratingId,
                    reason: reason,
                    details: details
                )
                print("Review reported successfully")
            } catch SupabaseServiceError.notAuthenticated {
                print("Report saved locally - user not authenticated")
                // Could store locally for later sync if needed
            } catch {
                print("Failed to submit report: \(error)")
            }
        }
    }
    
    // MARK: - UGC Compliance: Filtered Ratings (excluding blocked users)
    func filteredRatings(for dish: Dish) -> [DishRating] {
        dish.ratings.filter { !blockedUserIds.contains($0.userId) }
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Following System
    // ═══════════════════════════════════════════════════════════════════
    
    @Published var followingIds: Set<UUID> = []  // Users the current user follows
    @Published var followerIds: Set<UUID> = []   // Users following the current user
    @Published var followingUsers: [FollowUserInfo] = []  // Detailed info about followed users
    @Published var followerUsers: [FollowUserInfo] = []   // Detailed info about followers
    
    private let followingKey = "followingUserIds"
    
    // MARK: - Following Persistence
    private func loadFollowing() {
        if let data = UserDefaults.standard.data(forKey: followingKey),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            followingIds = ids
        }
    }
    
    private func saveFollowing() {
        if let data = try? JSONEncoder().encode(followingIds) {
            UserDefaults.standard.set(data, forKey: followingKey)
        }
    }
    
    // MARK: - Initialize Following (call this in init or after auth)
    func initializeFollowing() {
        loadFollowing()
        loadFollowingUsersFromMock()
    }
    
    // MARK: - Load Following Users (Mock Data for Demo)
    private func loadFollowingUsersFromMock() {
        // Convert followingIds to FollowUserInfo using MockData users
        followingUsers = followingIds.compactMap { userId in
            if let user = MockData.users.first(where: { $0.id == userId }) {
                return FollowUserInfo(
                    id: user.id,
                    username: user.username,
                    fullName: user.fullName,
                    avatarEmoji: user.avatarEmoji,
                    avatarImageName: user.avatarImageName,
                    bio: user.bio,
                    followedAt: Date()
                )
            }
            return nil
        }
    }
    
    // MARK: - Check if Following
    func isFollowing(_ userId: UUID) -> Bool {
        followingIds.contains(userId)
    }
    
    // MARK: - Follow User
    func followUser(_ userId: UUID) {
        guard !followingIds.contains(userId) else { return }
        
        followingIds.insert(userId)
        saveFollowing()
        loadFollowingUsersFromMock()
        
        // Sync with Supabase
        Task {
            do {
                _ = try await service.followUser(userId: userId)
                print("User followed successfully")
            } catch SupabaseServiceError.notAuthenticated {
                print("Follow saved locally - user not authenticated")
            } catch {
                print("Failed to sync follow: \(error)")
            }
        }
        
        objectWillChange.send()
    }
    
    // MARK: - Unfollow User
    func unfollowUser(_ userId: UUID) {
        guard followingIds.contains(userId) else { return }
        
        followingIds.remove(userId)
        saveFollowing()
        followingUsers.removeAll { $0.id == userId }
        
        // Sync with Supabase
        Task {
            do {
                _ = try await service.unfollowUser(userId: userId)
                print("User unfollowed successfully")
            } catch SupabaseServiceError.notAuthenticated {
                print("Unfollow saved locally - user not authenticated")
            } catch {
                print("Failed to sync unfollow: \(error)")
            }
        }
        
        objectWillChange.send()
    }
    
    // MARK: - Toggle Follow
    func toggleFollow(_ userId: UUID) {
        if isFollowing(userId) {
            unfollowUser(userId)
        } else {
            followUser(userId)
        }
    }
    
    // MARK: - Following Count
    var followingCount: Int {
        followingIds.count
    }
    
    // MARK: - Followers Count (placeholder for now)
    var followersCount: Int {
        followerIds.count
    }
    
    // MARK: - Activity from Following
    var followingActivity: [DishRating] {
        guard !followingIds.isEmpty else { return [] }
        
        return recentActivity.filter { rating in
            followingIds.contains(rating.userId) && !blockedUserIds.contains(rating.userId)
        }
    }
    
    // MARK: - Has Following (for Activity tab default)
    var hasFollowing: Bool {
        !followingIds.isEmpty
    }
}
