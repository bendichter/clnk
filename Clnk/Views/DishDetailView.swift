import SwiftUI

// Helper function to format rating counts
private func formatRatingCount(_ count: Int) -> String {
    count == 1 ? "1 rating" : "\(count) ratings"
}

struct DishDetailView: View {
    let dish: Dish
    let restaurant: Restaurant
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showRatingSheet = false
    @State private var showShareSheet = false
    @State private var selectedReviewSort: ReviewSort = .recent
    
    enum ReviewSort: String, CaseIterable {
        case recent = "Recent"
        case helpful = "Most Helpful"
        case highest = "Highest"
        case lowest = "Lowest"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                LargeDishImageView(
                    dish: dish,
                    height: 280,
                    accentColor: restaurant.cuisine.accentColor
                )
                
                // Content
                VStack(spacing: 24) {
                    // Title & Price
                    VStack(spacing: 12) {
                        Text(dish.name)
                            .font(.title.weight(.bold))
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            // Restaurant Link
                            NavigationLink {
                                RestaurantDetailView(restaurant: restaurant)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(restaurant.imageEmoji)
                                    Text(restaurant.name)
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(AppTheme.primary)
                            }
                            
                            Text("•")
                                .foregroundStyle(AppTheme.textTertiary)
                            
                            Text(dish.formattedPrice)
                                .font(.title3.weight(.bold))
                        }
                        
                        // Tags
                        DishTagsRow(dish: dish)
                    }
                    
                    // Rating Overview Card (Simplified)
                    VStack(spacing: 16) {
                        // Overall Rating
                        VStack(spacing: 8) {
                            if dish.averageRating > 0 {
                                Text(String(format: "%.1f", dish.averageRating))
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundStyle(dish.averageRating.ratingColor)
                                
                                StarRatingView(rating: dish.averageRating, size: 20, showNumber: false)
                                
                                Text("\(dish.ratings.count) ratings")
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(AppTheme.textSecondary)
                            } else {
                                Text("No reviews yet")
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                                
                                Text("Be the first to rate this cocktail")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Rate Button or User's Rating
                        if let userRating = restaurantViewModel.userRating(for: dish.id) {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("You rated this cocktail")
                                        .font(.subheadline.weight(.medium))
                                    Spacer()
                                    RatingBadge(rating: userRating.rating, size: .small)
                                }
                                
                                Button {
                                    showRatingSheet = true
                                } label: {
                                    Text("Update Rating")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.primary)
                                }
                            }
                        } else {
                            Button {
                                showRatingSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Rate This Cocktail")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .padding(20)
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 6)
                    
                    // Average Flavor Profile
                    if let avgFlavor = averageFlavorProfile {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Average Flavor Profile")
                                .font(.headline)

                            FlavorProfileSummary(
                                sweet: avgFlavor.sweet,
                                salty: avgFlavor.salty,
                                bitter: avgFlavor.bitter,
                                sour: avgFlavor.sour
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(AppTheme.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About This Cocktail")
                            .font(.headline)
                        
                        Text(dish.description)
                            .font(.body)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(4)
                        
                        // Category
                        HStack(spacing: 8) {
                            Text(dish.category.emoji)
                            Text(dish.category.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Reviews Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Reviews")
                                .font(.headline)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(ReviewSort.allCases, id: \.self) { sort in
                                    Button {
                                        selectedReviewSort = sort
                                    } label: {
                                        HStack {
                                            Text(sort.rawValue)
                                            if selectedReviewSort == sort {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedReviewSort.rawValue)
                                        .font(.subheadline)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        
                        if sortedRatings.isEmpty {
                            EmptyStateView(
                                icon: "text.bubble",
                                title: "No reviews yet",
                                message: "Be the first to review this cocktail!"
                            )
                            .padding(.vertical, 20)
                        } else {
                            ForEach(sortedRatings.prefix(10)) { rating in
                                ReviewCard(rating: rating)
                            }
                            
                            if sortedRatings.count > 10 {
                                Button {
                                    // Show all reviews
                                } label: {
                                    Text("See all \(sortedRatings.count) reviews")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(20)
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                }
            }
        }
        .background(AppTheme.backgroundSecondary)
        .sheet(isPresented: $showRatingSheet) {
            RateDishView(dish: dish, restaurant: restaurant)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showShareSheet) {
            let deepLink = DeepLink.drink(barId: restaurant.id, drinkId: dish.id)
            ShareSheet(items: [
                deepLink.shareText(barName: restaurant.name, drinkName: dish.name),
                deepLink.url
            ])
        }
    }
    
    private var averageFlavorProfile: (sweet: Double, salty: Double, bitter: Double, sour: Double)? {
        let ratingsWithFlavor = dish.ratings.filter {
            $0.sweet != nil || $0.salty != nil || $0.bitter != nil || $0.sour != nil
        }
        guard !ratingsWithFlavor.isEmpty else { return nil }
        let count = Double(ratingsWithFlavor.count)
        let sweet = ratingsWithFlavor.compactMap(\.sweet).reduce(0, +) / count
        let salty = ratingsWithFlavor.compactMap(\.salty).reduce(0, +) / count
        let bitter = ratingsWithFlavor.compactMap(\.bitter).reduce(0, +) / count
        let sour = ratingsWithFlavor.compactMap(\.sour).reduce(0, +) / count
        return (sweet: sweet, salty: salty, bitter: bitter, sour: sour)
    }

    private var sortedRatings: [DishRating] {
        // UGC: Filter out blocked users and ratings without comments
        let ratingsWithComments = dish.ratings.filter { 
            !$0.comment.isEmpty && !restaurantViewModel.blockedUserIds.contains($0.userId)
        }
        
        switch selectedReviewSort {
        case .recent:
            return ratingsWithComments.sorted { $0.date > $1.date }
        case .helpful:
            return ratingsWithComments.sorted { $0.helpful > $1.helpful }
        case .highest:
            return ratingsWithComments.sorted { $0.rating > $1.rating }
        case .lowest:
            return ratingsWithComments.sorted { $0.rating < $1.rating }
        }
    }
}

// MARK: - Review Card with Photos and Profile Navigation
struct ReviewCard: View {
    let rating: DishRating
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isExpanded = false
    @State private var animateHelpful = false
    @State private var showReportSheet = false
    
    private var isMarkedHelpful: Bool {
        restaurantViewModel.isMarkedHelpful(rating.id)
    }
    
    private var helpfulCount: Int {
        restaurantViewModel.helpfulCount(for: rating.id)
    }
    
    private var isOwnReview: Bool {
        authViewModel.currentUser?.id == rating.userId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with tappable avatar
            HStack(spacing: 12) {
                NavigationLink {
                    UserProfileView(
                        userId: rating.userId,
                        userName: rating.userName,
                        userEmoji: rating.userEmoji,
                        userAvatarImageName: rating.userAvatarImageName
                    )
                } label: {
                    AvatarView(emoji: rating.userEmoji, imageName: rating.userAvatarImageName, size: 40)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    NavigationLink {
                        UserProfileView(
                            userId: rating.userId,
                            userName: rating.userName,
                            userEmoji: rating.userEmoji,
                            userAvatarImageName: rating.userAvatarImageName
                        )
                    } label: {
                        Text(rating.userName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    
                    Text(rating.date.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                
                Spacer()
                
                RatingBadge(rating: rating.rating, size: .small)
                
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
                            .frame(width: 32, height: 32)
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(Circle())
                    }
                }
            }
            
            // Comment
            if !rating.comment.isEmpty {
                Text(rating.comment)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(isExpanded ? nil : 3)
            }

            // Flavor Profile
            if rating.sweet != nil || rating.salty != nil || rating.bitter != nil || rating.sour != nil {
                FlavorProfileSummary(
                    sweet: rating.sweet,
                    salty: rating.salty,
                    bitter: rating.bitter,
                    sour: rating.sour
                )
            }

            // Photo Thumbnails
            if !rating.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(rating.photos.enumerated()), id: \.offset) { _, photo in
                            ReviewPhotoThumbnail(photoId: photo)
                        }
                    }
                }
            }
            
            // Actions
            HStack(spacing: 16) {
                // Don't show helpful button for own reviews
                if !isOwnReview {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            restaurantViewModel.toggleHelpful(for: rating.id)
                            animateHelpful = true
                        }
                        // Reset animation state
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateHelpful = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isMarkedHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .scaleEffect(animateHelpful ? 1.3 : 1.0)
                            Text("Helpful")
                            if helpfulCount > 0 {
                                Text("(\(helpfulCount))")
                            }
                        }
                        .font(.caption.weight(isMarkedHelpful ? .semibold : .regular))
                        .foregroundStyle(isMarkedHelpful ? AppTheme.primary : AppTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                if !rating.comment.isEmpty && rating.comment.count > 100 {
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Text(isExpanded ? "Show less" : "Show more")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.primary)
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showReportSheet) {
            ReportReviewView(rating: rating)
        }
    }
}

// MARK: - Review Photo Thumbnail
struct ReviewPhotoThumbnail: View {
    let photoId: String
    @State private var loadedImage: UIImage?
    
    var body: some View {
        Group {
            if PhotoManager.isPhotoId(photoId) {
                // Real photo - load from storage
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    // Loading placeholder
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.backgroundTertiary)
                        .frame(width: 60, height: 60)
                        .overlay {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        .onAppear {
                            loadImage()
                        }
                }
            } else {
                // Legacy emoji photo
                Text(photoId)
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(AppTheme.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = PhotoManager.shared.loadPhoto(id: photoId)
            DispatchQueue.main.async {
                loadedImage = image
            }
        }
    }
}

#Preview {
    NavigationStack {
        DishDetailView(
            dish: MockData.restaurants[0].dishes[0],
            restaurant: MockData.restaurants[0]
        )
        .environmentObject(RestaurantViewModel())
        .environmentObject(AuthViewModel())
    }
}
