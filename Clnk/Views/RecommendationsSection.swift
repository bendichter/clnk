import SwiftUI

/// AI-powered recommendations section showing personalized dish suggestions
struct RecommendationsSection: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var isDismissed = false
    
    var body: some View {
        if !isDismissed && restaurantViewModel.showRecommendations && !restaurantViewModel.recommendations.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recommendations For You")
                                .font(.headline.weight(.bold))
                            
                            Text("Based on your \(restaurantViewModel.userRatings.count) ratings")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isDismissed = true
                            restaurantViewModel.dismissRecommendations()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .padding(.horizontal)
                
                // Recommendations Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(restaurantViewModel.recommendations.prefix(10), id: \.0.id) { recommendation in
                            NavigationLink {
                                DishDetailView(dish: recommendation.0, restaurant: recommendation.1)
                            } label: {
                                RecommendedDishCard(
                                    dish: recommendation.0,
                                    restaurant: recommendation.1,
                                    score: recommendation.2
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Why these recommendations?
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("We analyzed your rating history to find dishes you'll love:")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                            Text("Based on your \(restaurantViewModel.userRatings.count) ratings")
                        }
                        .font(.caption)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(.orange)
                            Text("Similar to dishes you've rated highly")
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 8)
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                        Text("How do these recommendations work?")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.orange)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.05),
                        Color.pink.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal)
        }
    }
}

/// Card showing a recommended dish with match score indicator
struct RecommendedDishCard: View {
    let dish: Dish
    let restaurant: Restaurant
    let score: Double
    
    private var matchPercentage: Int {
        Int(score * 100)
    }
    
    private var matchColor: Color {
        if score >= 0.8 {
            return .green
        } else if score >= 0.6 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Only show image area if dish has an actual image
            if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 160)
                        .clipped()
                    
                    // Match Score Badge
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("\(matchPercentage)%")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(matchColor)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 4)
                    .padding(10)
                }
                .frame(height: 160)
            } else if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 160)
                        .clipped()
                    
                    // Match Score Badge
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("\(matchPercentage)%")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(matchColor)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 4)
                    .padding(10)
                }
                .frame(height: 160)
            }
            
            // Dish Info
            VStack(alignment: .leading, spacing: 8) {
                // Show match score at top when there's no image
                if dish.imageName == nil && dish.imageData == nil {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("\(matchPercentage)% Match")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(matchColor)
                    .clipShape(Capsule())
                }
                
                // Dish Name
                Text(dish.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Restaurant
                HStack(spacing: 6) {
                    Text(restaurant.imageEmoji)
                        .font(.caption2)
                    Text(restaurant.name)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                HStack {
                    // Price
                    Text(dish.formattedPrice)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.orange)
                    
                    Spacer()
                    
                    // Rating
                    HStack(spacing: 4) {
                        if dish.ratings.count > 0 {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.starFilled)
                            Text(String(format: "%.1f", dish.averageRating))
                                .font(.caption.weight(.semibold))
                        } else {
                            Text("No reviews")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
                
                // Dietary Tags (compact)
                HStack(spacing: 4) {
                    if dish.isVegan {
                        DietaryTag(text: "Vegan", icon: "🌱")
                    } else if dish.isVegetarian {
                        DietaryTag(text: "Veg", icon: "🥬")
                    }
                    if dish.isGlutenFree {
                        DietaryTag(text: "GF", icon: "🌾")
                    }
                    if dish.isSpicy {
                        DietaryTag(text: "Spicy", icon: "🌶️")
                    }
                }
            }
            .padding(12)
            .background(AppTheme.backgroundPrimary)
        }
        .frame(width: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

/// Small dietary tag for compact display
struct DietaryTag: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(icon)
                .font(.caption2)
            Text(text)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(AppTheme.textSecondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(AppTheme.backgroundSecondary)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            RecommendationsSection()
                .environmentObject({
                    let vm = RestaurantViewModel()
                    vm.forceDemoMode = true
                    // Simulate user ratings
                    vm.userRatings = [
                        UUID(): DishRating(
                            id: UUID(),
                            dishId: UUID(),
                            userId: UUID(),
                            userName: "Test User",
                            userEmoji: "👤",
                            rating: 5.0,
                            comment: "Great!",
                            date: Date(),
                            helpful: 0,
                            photos: []
                        )
                    ]
                    vm.updateRecommendations()
                    return vm
                }())
        }
    }
}
