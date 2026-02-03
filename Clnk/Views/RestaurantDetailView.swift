import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var selectedCategory: DishCategory?
    @State private var selectedDietaryFilters: Set<DietaryFilter> = []
    @State private var showAllDishes = false
    @State private var showAddDish = false
    @State private var showMenuUpload = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Header
                ZStack(alignment: .bottomLeading) {
                    // Background Gradient
                    LinearGradient(
                        colors: [
                            restaurant.cuisine.accentColor,
                            restaurant.cuisine.accentColor.opacity(0.8),
                            restaurant.cuisine.accentColor.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 220)
                    
                    // Emoji decoration
                    HStack {
                        Spacer()
                        Text(restaurant.imageEmoji)
                            .font(.system(size: 120))
                            .opacity(0.3)
                            .offset(x: 30, y: 20)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Text(restaurant.cuisine.emoji)
                                .font(.title)
                            Text(restaurant.cuisine.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(restaurant.priceRange.display)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text(restaurant.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            // Rating
                            HStack(spacing: 6) {
                                if restaurant.averageRating > 0 {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", restaurant.averageRating))
                                        .fontWeight(.bold)
                                    Text("(\(restaurant.totalRatings))")
                                        .opacity(0.8)
                                } else {
                                    Text("No reviews")
                                        .opacity(0.8)
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            
                            // Dishes count
                            HStack(spacing: 6) {
                                Image(systemName: "fork.knife")
                                Text("\(restaurant.dishes.count) dishes")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 10)
                }
                
                // Main Content
                VStack(spacing: 24) {
                    // About Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                        
                        Text(restaurant.description)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(4)
                        
                        // Address
                        Button {
                            openMaps(for: restaurant.address)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.orange)
                                Text(restaurant.address)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .font(.caption)
                                    .foregroundStyle(.orange.opacity(0.7))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Top Rated Dishes (only show if there are rated dishes)
                    if !restaurant.topDishes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "🏆 Top Rated")
                            
                            ForEach(restaurant.topDishes) { dish in
                                NavigationLink {
                                    DishDetailView(dish: dish, restaurant: restaurant)
                                } label: {
                                    TopDishRow(dish: dish, rank: (restaurant.topDishes.firstIndex(where: { $0.id == dish.id }) ?? 0) + 1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(AppTheme.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Category Filter
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Menu")
                                .font(.title2.weight(.bold))
                            
                            Spacer()
                            
                            // NEW: Scan Menu button (for restaurant owners)
                            Button {
                                showMenuUpload = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.text.viewfinder")
                                    Text("Scan Menu")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.blue)
                            }
                            
                            Button {
                                showAddDish = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Dish")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.orange)
                            }
                        }
                        
                        // Search Bar and Filters (only show if restaurant has dishes)
                        if !restaurant.dishes.isEmpty {
                            HStack(spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(AppTheme.textTertiary)
                                    
                                    TextField("Search dishes...", text: $searchText)
                                        .focused($isSearchFocused)
                                        .textFieldStyle(.plain)
                                        .font(.subheadline)
                                        .autocorrectionDisabled()
                                    
                                    if !searchText.isEmpty {
                                        Button {
                                            withAnimation {
                                                searchText = ""
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(AppTheme.textTertiary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    CategoryPill(
                                        title: "All",
                                        emoji: "📋",
                                        isSelected: selectedCategory == nil
                                    ) {
                                        withAnimation { selectedCategory = nil }
                                    }
                                    
                                    ForEach(uniqueCategories, id: \.self) { category in
                                        CategoryPill(
                                            title: category.rawValue,
                                            emoji: category.emoji,
                                            isSelected: selectedCategory == category
                                        ) {
                                            withAnimation { selectedCategory = category }
                                        }
                                    }
                                }
                            }
                            
                            // Dietary Filter Chips
                            if hasDietaryOptions {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(availableDietaryFilters, id: \.self) { filter in
                                            DietaryFilterChip(
                                                filter: filter,
                                                isSelected: selectedDietaryFilters.contains(filter)
                                            ) {
                                                withAnimation {
                                                    if selectedDietaryFilters.contains(filter) {
                                                        selectedDietaryFilters.remove(filter)
                                                    } else {
                                                        selectedDietaryFilters.insert(filter)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if !selectedDietaryFilters.isEmpty {
                                            Button {
                                                withAnimation {
                                                    selectedDietaryFilters.removeAll()
                                                }
                                            } label: {
                                                Text("Clear")
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundStyle(.red)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Dishes Grid
                    LazyVStack(spacing: 12) {
                        if filteredDishes.isEmpty {
                            // Empty state
                            VStack(spacing: 16) {
                                Image(systemName: restaurant.dishes.isEmpty ? "fork.knife" : "magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundStyle(AppTheme.textTertiary)
                                
                                Text(restaurant.dishes.isEmpty ? "No dishes yet" : "No dishes found")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)
                                
                                Text(restaurant.dishes.isEmpty ? "Be the first to add a dish!" : "Try adjusting your search or filters")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach(filteredDishes) { dish in
                                NavigationLink {
                                    DishDetailView(dish: dish, restaurant: restaurant)
                                } label: {
                                    DishCard(dish: dish)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        // Share action
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                    }
                    
                    Button {
                        withAnimation {
                            restaurantViewModel.toggleFavorite(restaurant.id)
                        }
                    } label: {
                        Image(systemName: restaurantViewModel.isFavorite(restaurant.id) ? "heart.fill" : "heart")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(restaurantViewModel.isFavorite(restaurant.id) ? .red : .primary)
                    }
                }
            }
        }
        .background(AppTheme.backgroundSecondary)
        .sheet(isPresented: $showAddDish) {
            AddDishView(restaurant: restaurant)
        }
        .sheet(isPresented: $showMenuUpload) {
            MenuUploadView(restaurant: restaurant)
        }
    }
    
    private var uniqueCategories: [DishCategory] {
        let categories = Set(restaurant.dishes.map { $0.category })
        return Array(categories).sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var filteredDishes: [Dish] {
        var result = restaurant.dishes
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { dish in
                dish.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by dietary options
        for filter in selectedDietaryFilters {
            switch filter {
            case .vegan:
                result = result.filter { $0.isVegan }
            case .vegetarian:
                result = result.filter { $0.isVegetarian || $0.isVegan }
            case .glutenFree:
                result = result.filter { $0.isGlutenFree }
            }
        }
        
        // Sort by category order (appetizers first, desserts/drinks last)
        result = result.sorted { $0.category.sortOrder < $1.category.sortOrder }
        
        return result
    }
    
    private var hasDietaryOptions: Bool {
        restaurant.dishes.contains { $0.isVegan || $0.isVegetarian || $0.isGlutenFree }
    }
    
    private var availableDietaryFilters: [DietaryFilter] {
        var filters: [DietaryFilter] = []
        if restaurant.dishes.contains(where: { $0.isVegan }) {
            filters.append(.vegan)
        }
        if restaurant.dishes.contains(where: { $0.isVegetarian || $0.isVegan }) {
            filters.append(.vegetarian)
        }
        if restaurant.dishes.contains(where: { $0.isGlutenFree }) {
            filters.append(.glutenFree)
        }
        return filters
    }
    
    // MARK: - Maps Integration
    private func openMaps(for address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
        
        // Try Google Maps first
        let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedAddress)")!
        
        if UIApplication.shared.canOpenURL(googleMapsURL) {
            // Google Maps is installed
            UIApplication.shared.open(googleMapsURL)
        } else {
            // Fallback to Apple Maps
            let appleMapsURL = URL(string: "http://maps.apple.com/?address=\(encodedAddress)")!
            UIApplication.shared.open(appleMapsURL)
        }
    }
}

// MARK: - Dietary Filter Chip
struct DietaryFilterChip: View {
    let filter: DietaryFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(filter.emoji)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline.weight(.medium))
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(isSelected ? .white : filterColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? filterColor : filterColor.opacity(0.15))
            .clipShape(Capsule())
        }
    }
    
    private var filterColor: Color {
        switch filter {
        case .vegan: return .green
        case .vegetarian: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .glutenFree: return .orange
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange : AppTheme.backgroundPrimary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Top Dish Row
struct TopDishRow: View {
    let dish: Dish
    let rank: Int
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Dish Image with Rank Badge Overlay
            ZStack(alignment: .topLeading) {
                DishImageView(dish: dish, size: 80, cornerRadius: 12)
                
                // Rank Badge in Upper Left Corner
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 28, height: 28)
                    
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                .offset(x: -4, y: -4)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dish.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    if dish.isPopular {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Text(dish.description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 4) {
                        if dish.averageRating > 0 {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(AppTheme.starFilled)
                            Text(String(format: "%.1f", dish.averageRating))
                                .font(.caption.weight(.bold))
                            Text("(\(dish.ratings.count))")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                        } else {
                            Text("No reviews")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    
                    // Tags
                    HStack(spacing: 4) {
                        if dish.isSpicy {
                            Text("🌶️")
                                .font(.caption)
                        }
                        if dish.isVegetarian {
                            Text("🌱")
                                .font(.caption)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Price & User Rating
            VStack(alignment: .trailing, spacing: 8) {
                Text(dish.formattedPrice)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(16)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 3)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .gray
        }
    }
}

// MARK: - Dish Card
struct DishCard: View {
    let dish: Dish
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Dish Image
            DishImageView(dish: dish, size: 80, cornerRadius: 12)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dish.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    if dish.isPopular {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Text(dish.description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 4) {
                        if dish.averageRating > 0 {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(AppTheme.starFilled)
                            Text(String(format: "%.1f", dish.averageRating))
                                .font(.caption.weight(.bold))
                            Text("(\(dish.ratings.count))")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                        } else {
                            Text("No reviews")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    
                    // Tags
                    HStack(spacing: 4) {
                        if dish.isSpicy {
                            Text("🌶️")
                                .font(.caption)
                        }
                        if dish.isVegetarian {
                            Text("🌱")
                                .font(.caption)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Price & User Rating
            VStack(alignment: .trailing, spacing: 8) {
                Text(dish.formattedPrice)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(16)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 3)
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: MockData.restaurants[0])
            .environmentObject(RestaurantViewModel())
    }
}
