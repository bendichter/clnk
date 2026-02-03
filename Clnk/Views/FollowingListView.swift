//
//  FollowingListView.swift
//  Clnk
//
//  View to manage following/followers list
//

import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var selectedTab: FollowTab = .following
    
    enum FollowTab: String, CaseIterable {
        case following = "Following"
        case followers = "Followers"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("", selection: $selectedTab) {
                ForEach(FollowTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == .following {
                FollowingListContent()
            } else {
                FollowersListContent()
            }
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.backgroundSecondary)
    }
}

// MARK: - Following List Content
struct FollowingListContent: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        if restaurantViewModel.followingUsers.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "person.2")
                    .font(.system(size: 48))
                    .foregroundStyle(ClnkColors.Sage.shade500)
                
                Text("Not following anyone")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Find people to follow by viewing their profiles and tapping the Follow button!")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(restaurantViewModel.followingUsers) { user in
                    FollowingUserRow(user: user)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Followers List Content
struct FollowersListContent: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 48))
                .foregroundStyle(ClnkColors.Sage.shade500)
            
            Text("Followers feature coming soon")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("You'll be able to see who follows you here.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Following User Row
struct FollowingUserRow: View {
    let user: FollowUserInfo
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var showUnfollowAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink {
                UserProfileView(
                    userId: user.id,
                    userName: user.fullName,
                    userEmoji: user.avatarEmoji,
                    userAvatarImageName: user.avatarImageName,
                    userBio: user.bio
                )
            } label: {
                HStack(spacing: 12) {
                    ProfileAvatarView(
                        emoji: user.avatarEmoji,
                        imageName: user.avatarImageName,
                        profileImageData: nil,
                        size: 50
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                showUnfollowAlert = true
            } label: {
                Text("Following")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ClnkColors.Primary.shade700)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ClnkColors.Sage.shade300)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
        .alert("Unfollow \(user.fullName)?", isPresented: $showUnfollowAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Unfollow", role: .destructive) {
                restaurantViewModel.unfollowUser(user.id)
            }
        } message: {
            Text("You won't see their activity in your Following feed anymore.")
        }
    }
}

// MARK: - Profile Avatar View Helper (if not already defined elsewhere)
// This may already exist in your codebase - remove if duplicate
#if false
struct ProfileAvatarView: View {
    let emoji: String
    var imageName: String?
    var profileImageData: Data?
    var size: CGFloat = 44
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.backgroundSecondary)
                .frame(width: size, height: size)
            
            if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if let imageName = imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.5))
            }
        }
    }
}
#endif

#Preview {
    NavigationStack {
        FollowingListView()
            .environmentObject(RestaurantViewModel())
    }
}
