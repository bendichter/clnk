import SwiftUI

struct UserProfileView: View {
    let userId: UUID
    let userName: String
    let userEmoji: String
    var userAvatarImageName: String? = nil
    var userProfileImageData: Data? = nil
    var userBio: String? = nil
    
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showBlockAlert = false
    @State private var showUnblockAlert = false
    
    private var isOwnProfile: Bool {
        authViewModel.currentUser?.id == userId
    }
    
    private var isBlocked: Bool {
        restaurantViewModel.isUserBlocked(userId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    ProfileAvatarView(
                        emoji: userEmoji,
                        imageName: userAvatarImageName,
                        profileImageData: userProfileImageData,
                        size: 100
                    )
                    
                    // Name
                    Text(userName)
                        .font(.title2.weight(.bold))
                    
                    // Bio
                    if let bio = userBio, !bio.isEmpty {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Stats
                    HStack(spacing: 32) {
                        VStack(spacing: 4) {
                            Text("\(userReviews.count)")
                                .font(.title3.weight(.bold))
                            Text("Reviews")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        
                        VStack(spacing: 4) {
                            if averageRating > 0 {
                                Text(String(format: "%.1f", averageRating))
                                    .font(.title3.weight(.bold))
                            } else {
                                Text("—")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Text("Avg Rating")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(totalPhotos)")
                                .font(.title3.weight(.bold))
                            Text("Photos")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 20)
                
                // Reviews Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(userName)'s Reviews")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if userReviews.isEmpty {
                        EmptyStateView(
                            icon: "text.bubble",
                            title: "No reviews yet",
                            message: "This user hasn't submitted any reviews."
                        )
                        .padding(.vertical, 40)
                    } else {
                        ForEach(userReviews) { review in
                            UserReviewCard(review: review)
                        }
                    }
                }
                .padding()
                .background(AppTheme.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.backgroundSecondary)
        .toolbar {
            // UGC: Block/Unblock User (only for other users' profiles)
            if !isOwnProfile {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if isBlocked {
                            Button {
                                showUnblockAlert = true
                            } label: {
                                Label("Unblock User", systemImage: "person.crop.circle.badge.checkmark")
                            }
                        } else {
                            Button(role: .destructive) {
                                showBlockAlert = true
                            } label: {
                                Label("Block User", systemImage: "hand.raised")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body.weight(.semibold))
                    }
                }
            }
        }
        .alert("Block \(userName)?", isPresented: $showBlockAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Block", role: .destructive) {
                restaurantViewModel.blockUser(userId)
            }
        } message: {
            Text("You won't see reviews from this user anymore. You can unblock them later from Settings.")
        }
        .alert("Unblock \(userName)?", isPresented: $showUnblockAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Unblock") {
                restaurantViewModel.unblockUser(userId)
            }
        } message: {
            Text("You will start seeing this user's reviews again.")
        }
    }
    
    private var userReviews: [DishRating] {
        // UGC: Don't show reviews if this user is blocked (though we probably wouldn't navigate here)
        if restaurantViewModel.isUserBlocked(userId) && !isOwnProfile {
            return []
        }
        
        var reviews: [DishRating] = []
        for restaurant in restaurantViewModel.restaurants {
            for dish in restaurant.dishes {
                reviews.append(contentsOf: dish.ratings.filter { $0.userId == userId })
            }
        }
        return reviews.sorted { $0.date > $1.date }
    }
    
    private var averageRating: Double {
        guard !userReviews.isEmpty else { return 0 }
        return userReviews.reduce(0.0) { $0 + $1.rating } / Double(userReviews.count)
    }
    
    private var totalPhotos: Int {
        userReviews.reduce(0) { $0 + $1.photos.count }
    }
}

// MARK: - User Review Card
struct UserReviewCard: View {
    let review: DishRating
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var animateHelpful = false
    
    private var isMarkedHelpful: Bool {
        restaurantViewModel.isMarkedHelpful(review.id)
    }
    
    private var helpfulCount: Int {
        restaurantViewModel.helpfulCount(for: review.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with rating
            HStack {
                RatingBadge(rating: review.rating, size: .small)
                
                Spacer()
                
                Text(review.date.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            // Comment
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(3)
            }
            
            // Photos
            if !review.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(review.photos.enumerated()), id: \.offset) { _, photo in
                            Text(photo)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            
            // Helpful button
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        restaurantViewModel.toggleHelpful(for: review.id)
                        animateHelpful = true
                    }
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
                    .foregroundStyle(isMarkedHelpful ? .orange : AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(12)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            userName: "Sarah C.",
            userEmoji: "👩‍🦰",
            userAvatarImageName: "sarah_chen",
            userBio: "Food enthusiast exploring SF's culinary scene 🍜"
        )
        .environmentObject(RestaurantViewModel())
    }
}
