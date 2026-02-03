import SwiftUI

struct BlockedUsersView: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @Environment(\.dismiss) var dismiss
    @State private var userToUnblock: UUID?
    @State private var showUnblockAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if blockedUsers.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                        
                        Text("No Blocked Users")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Users you block won't be able to interact with your reviews, and you won't see their content.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Info Banner
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.blue)
                                
                                Text("You won't see reviews from blocked users anywhere in the app.")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            
                            // Blocked Users List
                            VStack(spacing: 12) {
                                ForEach(blockedUsers, id: \.userId) { blockedUser in
                                    BlockedUserRow(
                                        user: blockedUser,
                                        onUnblock: {
                                            userToUnblock = blockedUser.userId
                                            showUnblockAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Blocked Users")
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
            .alert("Unblock User?", isPresented: $showUnblockAlert) {
                Button("Cancel", role: .cancel) {
                    userToUnblock = nil
                }
                Button("Unblock", role: .destructive) {
                    if let userId = userToUnblock {
                        restaurantViewModel.unblockUser(userId)
                    }
                    userToUnblock = nil
                }
            } message: {
                Text("You will start seeing this user's reviews again.")
            }
        }
    }
    
    private var blockedUsers: [(userId: UUID, userName: String, userEmoji: String)] {
        // Get unique blocked users from all ratings
        var users: [UUID: (userName: String, userEmoji: String)] = [:]
        
        for restaurant in restaurantViewModel.restaurants {
            for dish in restaurant.dishes {
                for rating in dish.ratings {
                    if restaurantViewModel.blockedUserIds.contains(rating.userId) {
                        users[rating.userId] = (rating.userName, rating.userEmoji)
                    }
                }
            }
        }
        
        return users.map { (userId: $0.key, userName: $0.value.userName, userEmoji: $0.value.userEmoji) }
            .sorted { $0.userName < $1.userName }
    }
}

// MARK: - Blocked User Row
struct BlockedUserRow: View {
    let user: (userId: UUID, userName: String, userEmoji: String)
    let onUnblock: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(emoji: user.userEmoji, imageName: nil, size: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.userName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Blocked")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            Button {
                onUnblock()
            } label: {
                Text("Unblock")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    BlockedUsersView()
        .environmentObject(RestaurantViewModel())
}
