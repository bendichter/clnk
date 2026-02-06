import SwiftUI

// MARK: - App Theme
struct AppTheme {
    // Brand Colors - Deep Teal cocktail theme
    static let primary = Color("AccentColor")
    static let primaryGradient = LinearGradient(
        colors: [ClnkColors.Primary.shade800, ClnkColors.Accent.shade600],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    // Secondary dark teal accent
    static let secondaryGradient = LinearGradient(
        colors: [ClnkColors.Primary.shade900, ClnkColors.Primary.shade700],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Semantic Colors
    static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.35, blue: 0.35)
    
    // Rating Colors
    static let starFilled = Color(red: 1.0, green: 0.75, blue: 0.0)
    static let starEmpty = Color.gray.opacity(0.3)
    
    // Background
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)
    
    // Text
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    // Card Styles
    static let cardShadow = Color.black.opacity(0.08)
    static let cardRadius: CGFloat = 16
    
    // Animation
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let quickAnimation = Animation.easeOut(duration: 0.2)
}

// MARK: - Custom Modifiers
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isEnabled {
                        AppTheme.primaryGradient
                    } else {
                        Color.gray.opacity(0.5)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(AppTheme.quickAnimation, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.primaryGradient)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.primaryGradient, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(AppTheme.quickAnimation, value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
    
    func glassCard() -> some View {
        modifier(GlassCard())
    }
    
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
        )
        .clipped()
    }
}

// MARK: - Rating Badge Colors
extension Double {
    var ratingColor: Color {
        switch self {
        case 4.5...5.0: return Color(red: 0.2, green: 0.78, blue: 0.35)
        case 4.0..<4.5: return Color(red: 0.55, green: 0.78, blue: 0.25)
        case 3.5..<4.0: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case 3.0..<3.5: return Color(red: 1.0, green: 0.55, blue: 0.0)
        default: return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }
}
