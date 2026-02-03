import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var tabState: TabState
    @State private var searchText = ""
    @State private var selectedFilter: CuisineType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with greeting
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Restaurants.greeting(authViewModel.currentUser?.fullName.components(separatedBy: " ").first ?? "Foodie"))
                                .font(.title2.weight(.bold))
                            
                            Text(L10n.Restaurants.whatToEat)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        if let user = authViewModel.currentUser {
                            NavigationLink {
                                ProfileView()
                            } label: {
                                AvatarView(emoji: user.avatarEmoji, imageName: user.avatarImageName, profileImageData: user.profileImageData, size: 48)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Search Bar
                SearchBar(text: $searchText, placeholder: L10n.Restaurants.searchPlaceholder)
                    .padding(.horizontal)
                    .onChange(of: searchText) { _, newValue in
                        restaurantViewModel.searchText = newValue
                        restaurantViewModel.resetRestaurantsPagination()
                    }
                
                // Cuisine Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterPill(
                            title: L10n.Common.all,
                            isSelected: selectedFilter == nil,
                            icon: "sparkles"
                        ) {
                            withAnimation {
                                selectedFilter = nil
                                restaurantViewModel.selectedCuisine = nil
                                restaurantViewModel.resetRestaurantsPagination()
                            }
                        }
                        
                        ForEach(CuisineType.allCases, id: \.self) { cuisine in
                            FilterPill(
                                title: cuisine.rawValue,
                                isSelected: selectedFilter == cuisine,
                                emoji: cuisine.emoji
                            ) {
                                withAnimation {
                                    selectedFilter = cuisine
                                    restaurantViewModel.selectedCuisine = cuisine
                                    restaurantViewModel.resetRestaurantsPagination()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // AI Recommendations Section
                if selectedFilter == nil && searchText.isEmpty {
                    RecommendationsSection()
                }
                
                // Featured Section
                if selectedFilter == nil && searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: L10n.Restaurants.featured)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(restaurantViewModel.featuredRestaurants) { restaurant in
                                    NavigationLink {
                                        RestaurantDetailView(restaurant: restaurant)
                                    } label: {
                                        FeaturedRestaurantCard(restaurant: restaurant)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Restaurant List
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(
                        title: selectedFilter != nil ? "\(selectedFilter!.emoji) \(selectedFilter!.rawValue)" : L10n.Restaurants.allRestaurants,
                        action: L10n.Common.seeMap
                    ) {
                        tabState.switchToMap()
                    }
                    .padding(.horizontal)
                    
                    if restaurantViewModel.filteredRestaurants.isEmpty {
                        EmptyStateView(
                            icon: "fork.knife.circle",
                            title: L10n.Restaurants.noResults,
                            message: L10n.Restaurants.noResultsMessage
                        )
                        .padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(restaurantViewModel.paginatedRestaurants) { restaurant in
                                NavigationLink {
                                    RestaurantDetailView(restaurant: restaurant)
                                } label: {
                                    RestaurantCard(restaurant: restaurant)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Load More button
                            if restaurantViewModel.hasMoreRestaurants {
                                Button {
                                    withAnimation {
                                        restaurantViewModel.loadMoreRestaurants()
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("Load More")
                                            .font(.subheadline.weight(.semibold))
                                        Image(systemName: "chevron.down")
                                            .font(.caption.weight(.bold))
                                    }
                                    .foregroundStyle(.orange)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppTheme.backgroundPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(L10n.Tab.explore)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.backgroundSecondary)
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    var emoji: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.caption)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.orange : AppTheme.backgroundPrimary)
            .clipShape(Capsule())
            .shadow(color: isSelected ? .orange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Featured Restaurant Card
struct FeaturedRestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Image Area
            ZStack(alignment: .topTrailing) {
                ZStack {
                    LinearGradient(
                        colors: [
                            restaurant.cuisine.accentColor,
                            restaurant.cuisine.accentColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Text(restaurant.imageEmoji)
                        .font(.system(size: 60))
                        .offset(y: 10)
                }
                .frame(height: 140)
                
                // Favorite Button
                Button {
                    withAnimation {
                        restaurantViewModel.toggleFavorite(restaurant.id)
                    }
                } label: {
                    Image(systemName: restaurantViewModel.isFavorite(restaurant.id) ? "heart.fill" : "heart")
                        .font(.body.weight(.semibold))
                        .foregroundColor(restaurantViewModel.isFavorite(restaurant.id) ? .red : .white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(12)
            }
            
            // Info Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    RatingBadge(rating: restaurant.averageRating, size: .small)
                }
                
                HStack(spacing: 8) {
                    Text(restaurant.cuisine.emoji)
                    Text(restaurant.cuisine.rawValue)
                    Text("•")
                    Text(restaurant.priceRange.display)
                    
                    // Show distance if available
                    if let distance = restaurantViewModel.formattedDistance(to: restaurant) {
                        Text("•")
                        Text(distance)
                    }
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                
                // Top Dish Preview
                if let topDish = restaurant.topDishes.first {
                    HStack(spacing: 6) {
                        Text("🏆")
                        Text(L10n.Restaurants.topDish(topDish.name))
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                }
            }
            .padding(16)
            .background(AppTheme.backgroundPrimary)
        }
        .frame(width: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 6)
    }
}

// MARK: - Restaurant Card
struct RestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                restaurant.cuisine.accentColor.opacity(0.3),
                                restaurant.cuisine.accentColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                
                Text(restaurant.imageEmoji)
                    .font(.system(size: 40))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    if restaurant.isFeatured {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(restaurant.cuisine.emoji)
                    Text(restaurant.cuisine.rawValue)
                    Text("•")
                    Text(restaurant.priceRange.display)
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            if restaurant.averageRating > 0 {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(AppTheme.starFilled)
                                Text(String(format: "%.1f", restaurant.averageRating))
                                    .fontWeight(.bold)
                            } else {
                                Text("No reviews")
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .font(.subheadline)
                        
                        if restaurant.averageRating > 0 {
                            Text(L10n.Restaurants.ratingsCount(restaurant.totalRatings))
                                .font(.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    // Show distance if available
                    if let distance = restaurantViewModel.formattedDistance(to: restaurant) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(distance)
                        }
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                }
                
                Text(L10n.Restaurants.dishCount(restaurant.dishes.count))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            // Favorite Button
            Button {
                withAnimation {
                    restaurantViewModel.toggleFavorite(restaurant.id)
                }
            } label: {
                Image(systemName: restaurantViewModel.isFavorite(restaurant.id) ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(restaurantViewModel.isFavorite(restaurant.id) ? .red : AppTheme.textTertiary)
            }
        }
        .padding(16)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        RestaurantListView()
            .environmentObject(RestaurantViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(LocationManager())
            .environmentObject(TabState())
    }
}
