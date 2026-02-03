import SwiftUI

// Observable class for tab selection state
class TabState: ObservableObject {
    @Published var selectedTab: Int = 0
    
    func switchToExplore() {
        selectedTab = 0
    }
    
    func switchToMap() {
        selectedTab = 1
    }
}

struct MainTabView: View {
    @StateObject private var tabState = TabState()
    @State private var showRatingSheet = false
    @Namespace private var namespace
    
    var body: some View {
        TabView(selection: $tabState.selectedTab) {
            // Home / Explore Tab
            NavigationStack {
                RestaurantListView()
                    .environmentObject(tabState)
            }
            .tabItem {
                Label(L10n.Tab.explore, systemImage: "safari")
            }
            .tag(0)
            
            // Map Tab
            NavigationStack {
                RestaurantMapView()
            }
            .tabItem {
                Label(L10n.Tab.map, systemImage: "map")
            }
            .tag(1)
            
            // Search Tab
            NavigationStack {
                SearchView()
                    .environmentObject(tabState)
            }
            .tabItem {
                Label(L10n.Tab.search, systemImage: "magnifyingglass")
            }
            .tag(2)
            
            // Activity Tab
            NavigationStack {
                ActivityView()
            }
            .tabItem {
                Label(L10n.Tab.activity, systemImage: "bell")
            }
            .tag(3)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(L10n.Tab.profile, systemImage: "person.circle")
            }
            .tag(4)
        }
        .tint(.orange)
    }
}

// MARK: - Search View
struct SearchView: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var tabState: TabState
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: L10n.Search.placeholder)
                    .focused($isSearchFocused)
                    .padding(.horizontal)
                
                if searchText.isEmpty {
                    // Trending Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: L10n.Search.trending)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(restaurantViewModel.trendingDishes.prefix(8), id: \.dish.id) { item in
                                    NavigationLink {
                                        DishDetailView(dish: item.dish, restaurant: item.restaurant)
                                    } label: {
                                        TrendingDishCard(dish: item.dish, restaurant: item.restaurant)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Top Rated Dishes
                    if !restaurantViewModel.topRatedDishes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "⭐️ Top Rated Dishes")
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(restaurantViewModel.topRatedDishes.enumerated()), id: \.element.dish.id) { index, item in
                                    NavigationLink {
                                        DishDetailView(dish: item.dish, restaurant: item.restaurant)
                                    } label: {
                                        TopRatedDishRow(dish: item.dish, restaurant: item.restaurant, rank: index + 1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    // Search Results (dishes only - Explore handles restaurants)
                    let matchingDishes = findMatchingDishes()
                    if matchingDishes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.textTertiary)
                            Text("No dishes found")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Try a different search term")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(matchingDishes.count) dish\(matchingDishes.count == 1 ? "" : "es") found")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.horizontal)
                            
                            ForEach(matchingDishes.prefix(20), id: \.dish.id) { item in
                                NavigationLink {
                                    DishDetailView(dish: item.dish, restaurant: item.restaurant)
                                } label: {
                                    SearchDishRow(dish: item.dish, restaurant: item.restaurant)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(L10n.Search.title)
        .onAppear {
            isSearchFocused = true
        }
        .onChange(of: searchText) { _, newValue in
            restaurantViewModel.searchText = newValue
        }
    }
    
    private func findMatchingDishes() -> [(dish: Dish, restaurant: Restaurant)] {
        var results: [(dish: Dish, restaurant: Restaurant)] = []
        for restaurant in restaurantViewModel.restaurants {
            for dish in restaurant.dishes {
                if dish.name.localizedCaseInsensitiveContains(searchText) {
                    results.append((dish, restaurant))
                }
            }
        }
        return results
    }
}

// MARK: - Activity View
struct ActivityView: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    // UGC: Filter out blocked users
    private var filteredCommunityActivity: [DishRating] {
        restaurantViewModel.recentActivity.filter { 
            !restaurantViewModel.blockedUserIds.contains($0.userId)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Your Recent Ratings
                if !restaurantViewModel.userRatings.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Recent Ratings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(restaurantViewModel.userRatings.values).sorted { $0.date > $1.date }.prefix(5)) { rating in
                            ActivityCard(rating: rating)
                        }
                    }
                }
                
                // Community Activity (filtered to exclude blocked users)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Community Activity")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(filteredCommunityActivity.prefix(15)) { rating in
                        ActivityCard(rating: rating)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(L10n.Activity.title)
        .background(AppTheme.backgroundSecondary)
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let rating: DishRating
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showReportSheet = false
    
    private var isOwnReview: Bool {
        authViewModel.currentUser?.id == rating.userId
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            NavigationLink {
                UserProfileView(
                    userId: rating.userId,
                    userName: rating.userName,
                    userEmoji: rating.userEmoji,
                    userAvatarImageName: rating.userAvatarImageName
                )
            } label: {
                AvatarView(emoji: rating.userEmoji, imageName: rating.userAvatarImageName, size: 44)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(rating.userName)
                        .font(.subheadline.weight(.semibold))
                    Text(L10n.Activity.ratedADish)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                HStack(spacing: 8) {
                    StarRatingView(rating: rating.rating, size: 12, showNumber: false)
                    Text(String(format: "%.1f", rating.rating))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(rating.rating.ratingColor)
                }
                
                if !rating.comment.isEmpty {
                    Text(rating.comment)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }
                
                Text(rating.date.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            // UGC: Report Menu (only for other users' reviews)
            if !isOwnReview {
                Menu {
                    Button {
                        showReportSheet = true
                    } label: {
                        Label("Report Review", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.backgroundSecondary)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showReportSheet) {
            ReportReviewView(rating: rating)
        }
    }
}

// MARK: - Trending Dish Card
struct TrendingDishCard: View {
    let dish: Dish
    let restaurant: Restaurant
    
    /// Returns true if the dish has an actual image (not just emoji)
    private var hasImage: Bool {
        if let imageData = dish.imageData, UIImage(data: imageData) != nil {
            return true
        }
        if let imageName = dish.imageName, UIImage(named: imageName) != nil {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Only show image section if dish has an actual image
            if hasImage {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(restaurant.cuisine.accentColor.opacity(0.15))
                        .frame(height: 100)
                    
                    if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                
                Text(restaurant.name)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if dish.averageRating > 0 {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.starFilled)
                        Text(String(format: "%.1f", dish.averageRating))
                            .font(.caption.weight(.bold))
                    } else {
                        Text("No reviews")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .frame(width: 140)
    }
}

// MARK: - Search Result Rows
struct SearchRestaurantRow: View {
    let restaurant: Restaurant
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(restaurant.cuisine.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Text(restaurant.imageEmoji)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                HStack(spacing: 8) {
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
            }
            
            Spacer()
            
            RatingBadge(rating: restaurant.averageRating, size: .small)
        }
        .padding()
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct SearchDishRow: View {
    let dish: Dish
    let restaurant: Restaurant
    
    /// Returns true if the dish has an actual image (not just emoji)
    private var hasImage: Bool {
        if let imageData = dish.imageData, UIImage(data: imageData) != nil {
            return true
        }
        if let imageName = dish.imageName, UIImage(named: imageName) != nil {
            return true
        }
        return false
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Only show image if dish has one
            if hasImage {
                Group {
                    if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(L10n.Search.at(restaurant.name))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                RatingBadge(rating: dish.averageRating, size: .small)
                Text(dish.formattedPrice)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Top Rated Dish Row
struct TopRatedDishRow: View {
    let dish: Dish
    let restaurant: Restaurant
    let rank: Int
    
    private var rankBadgeColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.75)
        case 3: return .orange
        default: return AppTheme.textTertiary
        }
    }
    
    private var hasImage: Bool {
        if let imageData = dish.imageData, UIImage(data: imageData) != nil {
            return true
        }
        if let imageName = dish.imageName, UIImage(named: imageName) != nil {
            return true
        }
        return false
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            Text("\(rank)")
                .font(.headline.weight(.bold))
                .foregroundStyle(rankBadgeColor)
                .frame(width: 28)
            
            // Dish image (if available)
            if hasImage {
                Group {
                    if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text(restaurant.name)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", dish.averageRating))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                
                Text("\(dish.ratings.count) reviews")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding()
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(RestaurantViewModel())
        .environmentObject(LocationManager())
}
