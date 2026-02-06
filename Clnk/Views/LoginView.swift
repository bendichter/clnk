import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var animateGradient = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 60)
                        logoSection
                        loginCard
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
        .onChange(of: showSignUp) { _, _ in
            authViewModel.clearError()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                ClnkColors.Primary.shade800,
                ClnkColors.Primary.shade600,
                ClnkColors.Accent.shade600
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Text("🍸")
                    .font(.system(size: 60))
            }
            
            VStack(spacing: 8) {
                Text("Clnk")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Find your next great drink")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Login Card
    
    private var loginCard: some View {
        VStack(spacing: 24) {
            inputFields
            errorMessageView
            actionButtons
        }
        .padding(24)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Input Fields
    
    private var inputFields: some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .foregroundStyle(AppTheme.textTertiary)
                        .frame(width: 20)
                    
                    TextField("Enter your email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundStyle(AppTheme.textTertiary)
                        .frame(width: 20)
                    
                    SecureField("Enter your password", text: $password)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    // MARK: - Error Message
    
    @ViewBuilder
    private var errorMessageView: some View {
        if let error = authViewModel.errorMessage {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                Text(error)
            }
            .font(.caption)
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 24) {
            // Login Button
            Button {
                Task {
                    await authViewModel.login(email: email, password: password)
                }
            } label: {
                HStack(spacing: 8) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
            
            // Forgot Password
            Button {
                // TODO: Implement forgot password
            } label: {
                Text("Forgot Password?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            // Divider
            HStack(spacing: 16) {
                Rectangle()
                    .fill(AppTheme.textTertiary.opacity(0.3))
                    .frame(height: 1)
                
                Text("or")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                
                Rectangle()
                    .fill(AppTheme.textTertiary.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Sign Up Button
            Button {
                showSignUp = true
            } label: {
                Text("Create Account")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            // Demo Mode Button
            Button {
                restaurantViewModel.switchToDemoMode()
                authViewModel.loginAsDemo()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                    Text("Try Demo Mode")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.primary)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
