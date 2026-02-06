import SwiftUI

struct ReportReviewView: View {
    let rating: DishRating
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedReason: ReportReason?
    @State private var otherDetails: String = ""
    @State private var isSubmitting = false
    @FocusState private var isDetailsFocused: Bool
    
    enum ReportReason: String, CaseIterable {
        case inappropriate = "Inappropriate content"
        case spam = "Spam"
        case falseInfo = "False information"
        case harassment = "Harassment"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .inappropriate: return "exclamationmark.triangle"
            case .spam: return "envelope.badge"
            case .falseInfo: return "xmark.circle"
            case .harassment: return "hand.raised"
            case .other: return "ellipsis.circle"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "flag.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                            
                            Text("Report Review")
                                .font(.title2.weight(.bold))
                        }
                        
                        Text("Help us keep Clnk safe and trustworthy by reporting reviews that violate our community guidelines.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Review Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review Being Reported")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.textTertiary)
                            .textCase(.uppercase)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                AvatarView(emoji: rating.userEmoji, imageName: rating.userAvatarImageName, size: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rating.userName)
                                        .font(.subheadline.weight(.semibold))
                                    
                                    Text(rating.date.formatted(.relative(presentation: .named)))
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                
                                Spacer()
                                
                                RatingBadge(rating: rating.rating, size: .small)
                            }
                            
                            if !rating.comment.isEmpty {
                                Text(rating.comment)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(3)
                            }
                        }
                        .padding(12)
                        .background(AppTheme.backgroundSecondary.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.textTertiary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding()
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Report Reasons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reason for Report")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(ReportReason.allCases, id: \.self) { reason in
                                Button {
                                    selectedReason = reason
                                    if reason == .other {
                                        isDetailsFocused = true
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: reason.icon)
                                            .font(.title3)
                                            .foregroundStyle(selectedReason == reason ? AppTheme.primary : AppTheme.textSecondary)
                                            .frame(width: 28)
                                        
                                        Text(reason.rawValue)
                                            .font(.body)
                                            .foregroundStyle(AppTheme.textPrimary)
                                        
                                        Spacer()
                                        
                                        if selectedReason == reason {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppTheme.primary)
                                        } else {
                                            Circle()
                                                .stroke(AppTheme.textTertiary, lineWidth: 2)
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                    .padding(16)
                                    .background(selectedReason == reason ? 
                                        AppTheme.primary.opacity(0.1) : 
                                        AppTheme.backgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedReason == reason ? 
                                                AppTheme.primary : 
                                                AppTheme.textTertiary.opacity(0.2), 
                                                lineWidth: selectedReason == reason ? 2 : 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Additional Details (shown when "Other" is selected)
                    if selectedReason == .other {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Additional Details")
                                .font(.headline)
                            
                            ZStack(alignment: .topLeading) {
                                if otherDetails.isEmpty {
                                    Text("Please describe the issue...")
                                        .foregroundStyle(AppTheme.textTertiary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                
                                TextEditor(text: $otherDetails)
                                    .focused($isDetailsFocused)
                                    .frame(minHeight: 100)
                                    .scrollContentBackground(.hidden)
                            }
                            .padding(12)
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isDetailsFocused ? AppTheme.primary : AppTheme.textTertiary.opacity(0.2), lineWidth: isDetailsFocused ? 2 : 1)
                            )
                        }
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Submit Button
                    Button {
                        submitReport()
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "flag.fill")
                                Text("Submit Report")
                            }
                        }
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit ? .red : AppTheme.textTertiary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!canSubmit || isSubmitting)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isDetailsFocused = false
                    }
                }
            }
            .background(AppTheme.backgroundPrimary)
        }
    }
    
    private var canSubmit: Bool {
        guard let reason = selectedReason else { return false }
        if reason == .other {
            return !otherDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
    
    private func submitReport() {
        guard let reason = selectedReason else { return }
        
        isSubmitting = true
        
        let details = reason == .other ? otherDetails : nil
        
        restaurantViewModel.reportReview(
            ratingId: rating.id,
            reason: reason.rawValue,
            details: details
        )
        
        // Simulate submission delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview {
    ReportReviewView(
        rating: DishRating(
            id: UUID(),
            dishId: UUID(),
            userId: UUID(),
            userName: "John Doe",
            userEmoji: "🧑",
            rating: 4.5,
            comment: "This is a sample review that might need to be reported.",
            date: Date(),
            helpful: 5,
            photos: []
        )
    )
    .environmentObject(RestaurantViewModel())
}
