import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showAvatarPicker = false
    @State private var showBlockedUsers = false
    
    // Pagination state for reviews
    @State private var displayedReviewsCount: Int = 10
    @State private var isLoadingMoreReviews = false
    private let reviewsPageSize = 10
    
    // Computed property for sorted ratings
    private var sortedRatings: [DishRating] {
        Array(restaurantViewModel.userRatings.values).sorted(by: { $0.date > $1.date })
    }
    
    private var displayedRatings: [DishRating] {
        Array(sortedRatings.prefix(displayedReviewsCount))
    }
    
    private var hasMoreReviews: Bool {
        displayedReviewsCount < sortedRatings.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    Button {
                        showAvatarPicker = true
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            ProfileAvatarView(
                                emoji: authViewModel.currentUser?.avatarEmoji ?? "🧑",
                                imageName: authViewModel.currentUser?.avatarImageName,
                                profileImageData: authViewModel.currentUser?.profileImageData,
                                size: 100
                            )
                            
                            // Edit Badge
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primary)
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "pencil")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 4, y: 4)
                        }
                    }
                    
                    // Name & Username
                    VStack(spacing: 4) {
                        Text(authViewModel.currentUser?.fullName ?? "User")
                            .font(.title2.weight(.bold))
                        
                        Text("@\(authViewModel.currentUser?.username ?? "user")")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    // Bio
                    if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                    }
                    
                    // Member Since
                    if let joinDate = authViewModel.currentUser?.joinDate {
                        Text("Member since \(joinDate.formatted(.dateTime.month(.wide).year()))")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .padding(.top, 20)
                
                // Stats Cards
                HStack(spacing: 16) {
                    StatCard(
                        icon: "star.fill",
                        value: "\(restaurantViewModel.userRatings.count)",
                        label: "Ratings",
                        color: AppTheme.primary
                    )
                    
                    StatCard(
                        icon: "heart.fill",
                        value: "\(restaurantViewModel.favoriteRestaurants.count)",
                        label: "Favorites",
                        color: .red
                    )
                    
                    NavigationLink {
                        FollowingListView()
                    } label: {
                        StatCard(
                            icon: "person.2.fill",
                            value: "\(restaurantViewModel.followingCount)",
                            label: "Following",
                            color: ClnkColors.Primary.shade500
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                // Following Section (if following anyone)
                if restaurantViewModel.hasFollowing {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionHeader(title: "Following")
                            Spacer()
                            NavigationLink {
                                FollowingListView()
                            } label: {
                                Text("Manage")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(ClnkColors.Accent.shade600)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(restaurantViewModel.followingUsers.prefix(10)) { user in
                                    NavigationLink {
                                        UserProfileView(
                                            userId: user.id,
                                            userName: user.fullName,
                                            userEmoji: user.avatarEmoji,
                                            userAvatarImageName: user.avatarImageName,
                                            userBio: user.bio
                                        )
                                    } label: {
                                        VStack(spacing: 8) {
                                            ProfileAvatarView(
                                                emoji: user.avatarEmoji,
                                                imageName: user.avatarImageName,
                                                profileImageData: nil,
                                                size: 56
                                            )
                                            Text(user.fullName.components(separatedBy: " ").first ?? user.username)
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.textPrimary)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 72)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
                // Recent Activity - Paginated Reviews
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        SectionHeader(title: "Your Ratings")
                        
                        if !sortedRatings.isEmpty {
                            Spacer()
                            Text("\(displayedRatings.count) of \(sortedRatings.count)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    
                    if restaurantViewModel.userRatings.isEmpty {
                        EmptyStateView(
                            icon: "star",
                            title: "No ratings yet",
                            message: "Start rating cocktails to see them here!"
                        )
                        .padding(.vertical, 20)
                    } else {
                        // Display paginated reviews
                        LazyVStack(spacing: 12) {
                            ForEach(displayedRatings) { rating in
                                ProfileReviewCard(rating: rating)
                            }
                        }
                        
                        // Load More button
                        if hasMoreReviews {
                            Button {
                                loadMoreReviews()
                            } label: {
                                HStack(spacing: 8) {
                                    if isLoadingMoreReviews {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.down.circle")
                                    }
                                    Text(isLoadingMoreReviews ? "Loading..." : "Load More Reviews")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(AppTheme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isLoadingMoreReviews)
                            .padding(.top, 4)
                        }
                    }
                }
                .padding()
                .background(AppTheme.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Favorite Restaurants
                if !restaurantViewModel.favoriteRestaurants.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Favorite Restaurants")
                        
                        ForEach(restaurantViewModel.restaurants.filter { restaurantViewModel.isFavorite($0.id) }) { restaurant in
                            NavigationLink {
                                RestaurantDetailView(restaurant: restaurant)
                            } label: {
                                FavoriteRestaurantRow(restaurant: restaurant)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
                // Settings Section
                VStack(spacing: 0) {
                    SettingsRow(icon: "person.circle", title: "Edit Profile", color: .blue) {
                        showEditProfile = true
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    SettingsRow(icon: "bell.circle", title: "Notifications", color: .purple) {
                        // Notifications settings
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    SettingsRow(icon: "hand.raised.circle", title: "Blocked Users", color: .red) {
                        showBlockedUsers = true
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    SettingsRow(icon: "questionmark.circle", title: "Help & Support", color: .green) {
                        // Help
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    SettingsRow(icon: "info.circle", title: "About Clnk", color: .gray) {
                        // About
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", color: .red) {
                        showLogoutAlert = true
                    }
                }
                .background(AppTheme.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Version
                Text("Clnk v1.0.0")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.vertical, 20)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Profile")
        .background(AppTheme.backgroundSecondary)
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerView()
        }
        .sheet(isPresented: $showBlockedUsers) {
            BlockedUsersView()
        }
    }
    
    // MARK: - Load More Reviews
    private func loadMoreReviews() {
        guard !isLoadingMoreReviews, hasMoreReviews else { return }
        
        isLoadingMoreReviews = true
        
        // Simulate network delay for smooth UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                displayedReviewsCount = min(
                    displayedReviewsCount + reviewsPageSize,
                    sortedRatings.count
                )
            }
            isLoadingMoreReviews = false
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.weight(.bold))
            
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Profile Review Card (Enhanced with Star Rating Display)
struct ProfileReviewCard: View {
    let rating: DishRating
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var showFullReview = false
    @State private var showEditRating = false
    
    // Find the restaurant and dish for this rating
    private var dishInfo: (dish: Dish, restaurant: Restaurant)? {
        for restaurant in restaurantViewModel.restaurants {
            if let dish = restaurant.dishes.first(where: { $0.id == rating.dishId }) {
                return (dish, restaurant)
            }
        }
        return nil
    }
    
    var body: some View {
        Button {
            showEditRating = true
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEditRating) {
            if let info = dishInfo {
                EditRatingView(rating: rating, dish: info.dish, restaurant: info.restaurant)
            }
        }
        .sheet(isPresented: $showFullReview) {
            if let info = dishInfo {
                ReviewDetailView(rating: rating, dish: info.dish, restaurant: info.restaurant)
            }
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top row: Visual star rating and date
            HStack(alignment: .center) {
                // Visual star rating
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: starImageName(for: index))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(index <= Int(rating.rating.rounded()) ? ClnkColors.Gold.shade400 : AppTheme.textTertiary.opacity(0.4))
                    }
                    
                    Text(String(format: "%.1f", rating.rating))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.leading, 4)
                }
                
                Spacer()
                
                // Date
                Text(rating.date.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            // Restaurant and dish info section
            if let info = dishInfo {
                VStack(alignment: .leading, spacing: 10) {
                    // Restaurant name (tappable link)
                    NavigationLink {
                        RestaurantDetailView(restaurant: info.restaurant)
                    } label: {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(info.restaurant.cuisine.accentColor.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Text(info.restaurant.imageEmoji)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Restaurant")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textTertiary)
                                Text(info.restaurant.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AppTheme.primary.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)

                    // Dish name (tappable link)
                    NavigationLink {
                        DishDetailView(dish: info.dish, restaurant: info.restaurant)
                    } label: {
                        HStack(spacing: 8) {
                            // Only show image if dish has one
                            if let imageData = info.dish.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else if let imageName = info.dish.imageName, let uiImage = UIImage(named: imageName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cocktail")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textTertiary)
                                Text(info.dish.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppTheme.primary)
                            }
                            
                            Spacer()
                            
                            Text(info.dish.formattedPrice)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.textSecondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AppTheme.primary.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Review text/comment (if any)
            if !rating.comment.isEmpty {
                Button {
                    showFullReview = true
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "quote.opening")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.primary)
                            Text("Review")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        
                        Text(rating.comment)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(AppTheme.backgroundPrimary.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppTheme.textTertiary.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow.opacity(0.5), radius: 4, x: 0, y: 2)
    }
    
    // Helper function for star images
    private func starImageName(for index: Int) -> String {
        let ratingValue = rating.rating
        if Double(index) <= ratingValue {
            return "star.fill"
        } else if Double(index) - 0.5 <= ratingValue {
            return "star.leadinghalf.filled"
        }
        return "star"
    }
}

// MARK: - User Rating Card (Legacy - kept for compatibility)
struct UserRatingCard: View {
    let rating: DishRating
    
    var body: some View {
        ProfileReviewCard(rating: rating)
    }
}

// MARK: - Review Detail View (Full Review)
struct ReviewDetailView: View {
    let rating: DishRating
    let dish: Dish
    let restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with dish and restaurant info
                    VStack(alignment: .leading, spacing: 16) {
                        // Rating badge and date
                        HStack {
                            RatingBadge(rating: rating.rating, size: .large)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(rating.date.formatted(.dateTime.month(.wide).day().year()))
                                    .font(.subheadline.weight(.medium))
                                Text(rating.date.formatted(.dateTime.hour().minute()))
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        
                        Divider()
                        
                        // Restaurant link
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(restaurant.cuisine.accentColor.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Text(restaurant.imageEmoji)
                                        .font(.title3)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Restaurant")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textTertiary)
                                    Text(restaurant.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .padding(12)
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        // Dish link
                        NavigationLink {
                            DishDetailView(dish: dish, restaurant: restaurant)
                        } label: {
                            HStack(spacing: 12) {
                                // Only show image if dish has one
                                if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Cocktail")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textTertiary)
                                    Text(dish.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                }

                                Spacer()

                                Text(dish.formattedPrice)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppTheme.textSecondary)

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .padding(12)
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(AppTheme.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Full review text
                    if !rating.comment.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.quote")
                                    .foregroundStyle(AppTheme.primary)
                                Text("Your Review")
                                    .font(.headline)
                            }
                            
                            Text(rating.comment)
                                .font(.body)
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Photos if any
                    if !rating.photos.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundStyle(AppTheme.primary)
                                Text("Photos")
                                    .font(.headline)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(rating.photos.enumerated()), id: \.offset) { _, photo in
                                        Text(photo)
                                            .font(.system(size: 40))
                                            .frame(width: 80, height: 80)
                                            .background(AppTheme.backgroundSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .navigationTitle("Review Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .background(AppTheme.backgroundSecondary)
        }
    }
}

// MARK: - Favorite Restaurant Row
struct FavoriteRestaurantRow: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(restaurant.cuisine.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Text(restaurant.imageEmoji)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(restaurant.cuisine.rawValue)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(12)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(title == "Sign Out" ? .red : AppTheme.textPrimary)
                
                Spacer()
                
                if title != "Sign Out" {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var username = ""
    @State private var bio = ""
    @FocusState private var isBioFocused: Bool
    
    private let bioCharacterLimit = 150
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $fullName)
                    TextField("Username", text: $username)
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("Tell others about yourself...")
                                .foregroundStyle(AppTheme.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $bio)
                            .focused($isBioFocused)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .onChange(of: bio) { _, newValue in
                                if newValue.count > bioCharacterLimit {
                                    bio = String(newValue.prefix(bioCharacterLimit))
                                }
                            }
                    }
                } header: {
                    Text("Bio")
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(bio.count)/\(bioCharacterLimit)")
                            .font(.caption)
                            .foregroundStyle(bio.count >= bioCharacterLimit ? .red : AppTheme.textTertiary)
                    }
                }
                
                Section("Email") {
                    Text(authViewModel.currentUser?.email ?? "")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        authViewModel.updateProfile(fullName: fullName, username: username, bio: bio)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isBioFocused = false
                    }
                }
            }
            .onAppear {
                fullName = authViewModel.currentUser?.fullName ?? ""
                username = authViewModel.currentUser?.username ?? ""
                bio = authViewModel.currentUser?.bio ?? ""
            }
        }
    }
}

// MARK: - Camera Picker (UIViewControllerRepresentable)
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Avatar Picker View (Emoji Only)
struct AvatarPickerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedEmoji: String = ""
    
    let avatarOptions = [
        "🧑", "👩", "👨", "🧑‍🦱", "👩‍🦰", "👨‍🦳", "🧑‍🦲", "👱",
        "👱‍♀️", "👴", "👵", "🧔", "👩‍🦱", "👨‍🦱", "👩‍🦳", "🧑‍🦳",
        "🤴", "👸", "🦸", "🦹", "🧙", "🧝", "🧛", "🧜",
        "🐱", "🐶", "🐼", "🐨", "🦊", "🦁", "🐯", "🐻"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Preview
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ClnkColors.Primary.shade500.opacity(0.3), ClnkColors.Accent.shade600.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Text(selectedEmoji.isEmpty ? (authViewModel.currentUser?.avatarEmoji ?? "🧑") : selectedEmoji)
                        .font(.system(size: 60))
                }
                .padding(.top, 20)
                
                Text("Choose Your Avatar")
                    .font(.headline)
                
                // Emoji Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(avatarOptions, id: \.self) { emoji in
                            Button {
                                withAnimation {
                                    selectedEmoji = emoji
                                }
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        selectedEmoji == emoji ?
                                        AppTheme.primary.opacity(0.3) :
                                        AppTheme.backgroundSecondary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedEmoji == emoji ? AppTheme.primary : .clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !selectedEmoji.isEmpty {
                            authViewModel.updateAvatar(selectedEmoji)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedEmoji.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(RestaurantViewModel())
    }
}
