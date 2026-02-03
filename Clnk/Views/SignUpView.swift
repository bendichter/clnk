import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var currentStep = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("👋")
                            .font(.system(size: 50))
                    }
                    
                    Text("Join Great Plate")
                        .font(.title.weight(.bold))
                    
                    Text("Track the dishes you love")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, 20)
                
                // Progress Indicators
                HStack(spacing: 8) {
                    ForEach(0..<3) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.orange : AppTheme.backgroundSecondary)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 40)
                
                // Form
                VStack(spacing: 24) {
                    // Step 1: Basic Info
                    if currentStep >= 0 {
                        VStack(spacing: 16) {
                            StyledTextField(
                                title: "Full Name",
                                text: $fullName,
                                icon: "person"
                            )
                            .onChange(of: fullName) { _, _ in updateStep() }
                            
                            StyledTextField(
                                title: "Email",
                                text: $email,
                                icon: "envelope",
                                keyboardType: .emailAddress
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: email) { _, _ in updateStep() }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                    // Step 2: Username & Password
                    if currentStep >= 1 {
                        VStack(spacing: 16) {
                            StyledTextField(
                                title: "Username",
                                text: $username,
                                icon: "at"
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: username) { _, _ in updateStep() }
                            
                            StyledTextField(
                                title: "Password",
                                text: $password,
                                icon: "lock",
                                isSecure: true
                            )
                            .onChange(of: password) { _, _ in updateStep() }
                            
                            // Password Requirements
                            VStack(alignment: .leading, spacing: 6) {
                                PasswordRequirement(
                                    text: "At least 6 characters",
                                    isMet: password.count >= 6
                                )
                                PasswordRequirement(
                                    text: "Contains a number",
                                    isMet: password.contains(where: { $0.isNumber })
                                )
                            }
                            .padding(.leading, 4)
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                    // Step 3: Confirm & Terms
                    if currentStep >= 2 {
                        VStack(spacing: 16) {
                            StyledTextField(
                                title: "Confirm Password",
                                text: $confirmPassword,
                                icon: "lock.shield",
                                isSecure: true
                            )
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text("Passwords don't match")
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            
                            // Terms Agreement
                            Button {
                                withAnimation {
                                    agreedToTerms.toggle()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                        .font(.title3)
                                        .foregroundStyle(agreedToTerms ? .orange : AppTheme.textTertiary)
                                    
                                    Text("I agree to the Terms of Service and Privacy Policy")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 8)
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
                
                // Error Message
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
                    .padding(.horizontal, 24)
                }
                
                // Sign Up Button
                Button {
                    Task {
                        await authViewModel.signUp(
                            fullName: fullName,
                            email: email,
                            username: username,
                            password: password
                        )
                    }
                } label: {
                    HStack(spacing: 8) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                            Image(systemName: "arrow.right")
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!isFormValid || authViewModel.isLoading)
                .padding(.horizontal, 24)
                
                // Back to Login
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
        .animation(AppTheme.springAnimation, value: currentStep)
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !username.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword &&
        agreedToTerms
    }
    
    private func updateStep() {
        if !fullName.isEmpty && !email.isEmpty && email.contains("@") {
            if currentStep < 1 {
                currentStep = 1
            }
            if !username.isEmpty && password.count >= 6 {
                if currentStep < 2 {
                    currentStep = 2
                }
            }
        }
    }
}

struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(isMet ? .green : AppTheme.textTertiary)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(isMet ? AppTheme.textPrimary : AppTheme.textTertiary)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
