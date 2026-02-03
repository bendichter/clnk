import Foundation
import SwiftUI
import UIKit
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Supabase client
    private let supabase = SupabaseClientManager.shared.client
    private let service = SupabaseService.shared
    
    // Key for storing custom profile image in UserDefaults
    private let profileImageKey = "userProfileImageData"
    
    init() {
        // Check for existing session
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Management
    
    /// Check for existing auth session
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            await handleSession(session)
        } catch {
            // No session, user not logged in
            print("No existing session: \(error.localizedDescription)")
        }
    }
    
    /// Handle auth session changes
    private func handleSession(_ session: Session?) async {
        guard let session = session else {
            withAnimation(AppTheme.springAnimation) {
                currentUser = nil
                isAuthenticated = false
            }
            return
        }
        
        // Fetch profile from Supabase
        do {
            if let profile = try await service.fetchProfile() {
                let user = profile.toUser()
                withAnimation(AppTheme.springAnimation) {
                    currentUser = User(
                        id: user.id,
                        username: user.username,
                        email: session.user.email ?? "",
                        fullName: user.fullName,
                        avatarEmoji: user.avatarEmoji,
                        avatarImageName: nil,
                        profileImageData: nil,
                        bio: user.bio,
                        joinDate: user.joinDate,
                        ratingsCount: user.ratingsCount,
                        favoriteRestaurants: user.favoriteRestaurants
                    )
                    isAuthenticated = true
                }
                
                // Load saved profile image if any
                loadSavedProfileImage()
            }
        } catch {
            print("Error fetching profile: \(error)")
            // Create minimal user from session
            withAnimation(AppTheme.springAnimation) {
                currentUser = User(
                    id: session.user.id,
                    username: session.user.email?.components(separatedBy: "@").first ?? "user",
                    email: session.user.email ?? "",
                    fullName: session.user.userMetadata["full_name"]?.value as? String ?? "",
                    avatarEmoji: "🧑",
                    bio: "",
                    joinDate: Date(),
                    ratingsCount: 0,
                    favoriteRestaurants: []
                )
                isAuthenticated = true
            }
        }
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            await handleSession(session)
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up
    
    func signUp(fullName: String, email: String, username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Basic validation
        guard !fullName.isEmpty, !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            isLoading = false
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        do {
            // Sign up with Supabase Auth
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
            
            // Update profile with username
            if response.session != nil {
                // Profile is auto-created by trigger, update with username
                do {
                    _ = try await service.updateProfile(
                        username: username,
                        fullName: fullName
                    )
                } catch {
                    print("Warning: Could not update profile: \(error)")
                }
                
                await handleSession(response.session)
            } else {
                // Email confirmation required
                errorMessage = "Please check your email to confirm your account"
            }
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout() {
        Task {
            do {
                try await supabase.auth.signOut()
                withAnimation(AppTheme.springAnimation) {
                    currentUser = nil
                    isAuthenticated = false
                }
            } catch {
                print("Logout error: \(error)")
                // Force local logout anyway
                withAnimation(AppTheme.springAnimation) {
                    currentUser = nil
                    isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Update Profile
    
    func updateProfile(fullName: String, username: String, bio: String) {
        guard var user = currentUser else { return }
        
        Task {
            do {
                let profile = try await service.updateProfile(
                    username: username,
                    fullName: fullName,
                    bio: bio
                )
                
                user.fullName = profile.fullName ?? fullName
                user.username = profile.username ?? username
                user.bio = profile.bio ?? bio
                currentUser = user
            } catch {
                print("Update profile error: \(error)")
                // Update locally anyway for responsiveness
                user.fullName = fullName
                user.username = username
                user.bio = bio
                currentUser = user
            }
        }
    }
    
    // MARK: - Update Avatar Emoji
    
    func updateAvatar(_ emoji: String) {
        guard var user = currentUser else { return }
        
        Task {
            do {
                _ = try await service.updateProfile(avatarEmoji: emoji)
                user.avatarEmoji = emoji
                user.avatarImageName = nil // Clear image when emoji is selected
                currentUser = user
            } catch {
                print("Update avatar error: \(error)")
                // Update locally anyway
                user.avatarEmoji = emoji
                currentUser = user
            }
        }
    }
    
    // MARK: - Update Avatar Image (preset)
    
    func updateAvatarImage(_ imageName: String?) {
        guard var user = currentUser else { return }
        user.avatarImageName = imageName
        user.profileImageData = nil // Clear custom image when preset is selected
        clearSavedProfileImage()
        currentUser = user
    }
    
    // MARK: - Update Custom Profile Image
    
    func updateProfileImage(_ image: UIImage) {
        guard var user = currentUser else { return }
        
        // Resize and compress the image
        if let resizedImage = resizeImage(image, maxSize: CGSize(width: 500, height: 500)),
           let imageData = resizedImage.jpegData(compressionQuality: 0.8) {
            
            // Upload to Supabase
            Task {
                do {
                    let avatarUrl = try await service.uploadAvatar(imageData: imageData)
                    print("Uploaded avatar: \(avatarUrl)")
                } catch {
                    print("Avatar upload error: \(error)")
                }
            }
            
            // Update locally
            user.profileImageData = imageData
            user.avatarImageName = nil // Clear preset image when custom is set
            saveProfileImageToStorage(imageData)
            currentUser = user
        }
    }
    
    // MARK: - Clear Custom Profile Image
    
    func clearCustomProfileImage() {
        guard var user = currentUser else { return }
        user.profileImageData = nil
        clearSavedProfileImage()
        currentUser = user
    }
    
    // MARK: - Image Resizing
    
    private func resizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage? {
        let size = image.size
        
        // Check if resizing is needed
        if size.width <= maxSize.width && size.height <= maxSize.height {
            return image
        }
        
        // Calculate the new size maintaining aspect ratio
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Create a new image context and draw the resized image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    // MARK: - Profile Image Storage (Local Cache)
    
    private func saveProfileImageToStorage(_ imageData: Data) {
        UserDefaults.standard.set(imageData, forKey: profileImageKey)
    }
    
    private func loadProfileImageFromStorage() -> Data? {
        return UserDefaults.standard.data(forKey: profileImageKey)
    }
    
    private func clearSavedProfileImage() {
        UserDefaults.standard.removeObject(forKey: profileImageKey)
    }
    
    // MARK: - Load Saved Profile Image (call on app launch if needed)
    
    func loadSavedProfileImage() {
        guard var user = currentUser else { return }
        if let savedImageData = loadProfileImageFromStorage() {
            user.profileImageData = savedImageData
            currentUser = user
        }
    }
    
    // MARK: - Update Bio
    
    func updateBio(_ bio: String) {
        guard var user = currentUser else { return }
        
        Task {
            do {
                _ = try await service.updateProfile(bio: bio)
                user.bio = bio
                currentUser = user
            } catch {
                print("Update bio error: \(error)")
                user.bio = bio
                currentUser = user
            }
        }
    }
    
    // MARK: - Clear Error
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Password Reset
    
    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            errorMessage = "Password reset email sent. Check your inbox."
        } catch {
            errorMessage = "Failed to send reset email: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Demo Login (bypasses Supabase)
    
    /// Login with demo account - uses MockData, no network required
    func loginAsDemo() {
        isLoading = true
        errorMessage = nil
        
        // Use Sarah Chen from MockData (first user)
        let demoUser = MockData.users.first ?? MockData.guestUser
        
        // Small delay to simulate network
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(AppTheme.springAnimation) {
                self.currentUser = demoUser
                self.isAuthenticated = true
            }
            self.isLoading = false
        }
    }
    
    /// Check if current session is demo mode (not connected to Supabase)
    var isDemoMode: Bool {
        guard let user = currentUser else { return false }
        return MockData.users.contains { $0.id == user.id } || user.id == MockData.guestUser.id
    }
}
