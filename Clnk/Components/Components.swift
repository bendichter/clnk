import SwiftUI

// MARK: - Dish Image View
struct DishImageView: View {
    let dish: Dish
    var size: CGFloat = 80
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        Group {
            if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                // User-added photo
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                // Asset image
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                // Fallback to clean gradient
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.4),
                                Color.red.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
            }
        }
    }
}

// MARK: - Large Dish Image View (for detail pages)
struct LargeDishImageView: View {
    let dish: Dish
    var height: CGFloat = 280
    var accentColor: Color = .orange
    
    /// Returns true if the dish has an actual image (not just emoji)
    var hasImage: Bool {
        if let imageData = dish.imageData, UIImage(data: imageData) != nil {
            return true
        }
        if let imageName = dish.imageName, UIImage(named: imageName) != nil {
            return true
        }
        return false
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                // User-added photo
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                // Asset image
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                // Clean minimal gradient header - no emoji placeholder
                LinearGradient(
                    colors: [
                        accentColor.opacity(0.4),
                        accentColor.opacity(0.2),
                        AppTheme.backgroundPrimary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: height * 0.6) // Shorter height when no image
            }
        }
    }
}

// MARK: - Star Rating Display
struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5
    var size: CGFloat = 14
    var spacing: CGFloat = 2
    var showNumber: Bool = true
    
    var body: some View {
        HStack(spacing: spacing) {
            if rating > 0 {
                ForEach(1...maxRating, id: \.self) { index in
                    Image(systemName: starType(for: index))
                        .font(.system(size: size, weight: .semibold))
                        .foregroundStyle(
                            index <= Int(rating.rounded()) ? 
                            AppTheme.starFilled : AppTheme.starEmpty
                        )
                }
                
                if showNumber {
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: size, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            } else {
                Text("No reviews")
                    .font(.system(size: size, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        if Double(index) <= rating {
            return "star.fill"
        } else if Double(index) - 0.5 <= rating {
            return "star.leadinghalf.filled"
        }
        return "star"
    }
}

// MARK: - Interactive Star Rating
struct InteractiveStarRating: View {
    @Binding var rating: Double
    var size: CGFloat = 32
    var label: String = ""
    var subtitle: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            if !label.isEmpty {
                HStack {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(ratingText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(rating > 0 ? rating.ratingColor : AppTheme.textTertiary)
                }
            }
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                        .font(.system(size: size, weight: .semibold))
                        .foregroundStyle(index <= Int(rating) ? AppTheme.starFilled : AppTheme.starEmpty)
                        .onTapGesture {
                            withAnimation(AppTheme.springAnimation) {
                                rating = Double(index)
                            }
                        }
                        .scaleEffect(index <= Int(rating) ? 1.1 : 1.0)
                        .animation(AppTheme.springAnimation, value: rating)
                }
            }
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }
    
    private var ratingText: String {
        switch Int(rating) {
        case 5: return "Excellent!"
        case 4: return "Very Good"
        case 3: return "Good"
        case 2: return "Fair"
        case 1: return "Poor"
        default: return "Tap to rate"
        }
    }
}

// MARK: - Rating Badge
struct RatingBadge: View {
    let rating: Double
    var size: BadgeSize = .medium
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 18
            }
        }
        
        var padding: (h: CGFloat, v: CGFloat) {
            switch self {
            case .small: return (6, 4)
            case .medium: return (10, 6)
            case .large: return (14, 8)
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if rating > 0 {
                Image(systemName: "star.fill")
                    .font(.system(size: size.fontSize - 2, weight: .bold))
                Text(String(format: "%.1f", rating))
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
            } else {
                Text("No reviews")
                    .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, size.padding.h)
        .padding(.vertical, size.padding.v)
        .background(rating > 0 ? rating.ratingColor : AppTheme.textSecondary)
        .clipShape(Capsule())
    }
}

// MARK: - Price Tag
struct PriceTag: View {
    let price: Double
    var style: PriceStyle = .normal
    
    enum PriceStyle {
        case normal, prominent
    }
    
    var body: some View {
        Text(String(format: "$%.2f", price))
            .font(style == .prominent ? .title3.weight(.bold) : .subheadline.weight(.semibold))
            .foregroundStyle(style == .prominent ? AppTheme.textPrimary : AppTheme.textSecondary)
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let text: String
    let icon: String?
    var color: Color = .orange
    
    init(_ text: String, icon: String? = nil, color: Color = .orange) {
        self.text = text
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
            }
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Dish Tags Row
struct DishTagsRow: View {
    let dish: Dish
    
    var body: some View {
        HStack(spacing: 6) {
            if dish.isPopular {
                TagChip("Popular", icon: "flame.fill", color: .orange)
            }
            if dish.isSpicy {
                TagChip("Spicy", icon: "flame", color: .red)
            }
            if dish.isVegan {
                TagChip("Vegan", icon: "leaf.fill", color: .green)
            } else if dish.isVegetarian {
                TagChip("Vegetarian", icon: "leaf", color: Color(red: 0.2, green: 0.6, blue: 0.3))
            }
            if dish.isGlutenFree {
                TagChip("GF", icon: nil, color: .orange)
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(.body)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Custom Text Field
struct StyledTextField: View {
    let title: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(AppTheme.textTertiary)
                        .frame(width: 20)
                }
                
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.textTertiary)
            
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(message)
                .font(.body)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 60)
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Rating Breakdown Row
struct RatingBreakdownRow: View {
    let title: String
    let icon: String
    let rating: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(rating.ratingColor)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
            
            Spacer()
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.backgroundSecondary)
                    
                    Capsule()
                        .fill(rating.ratingColor)
                        .frame(width: geo.size.width * (rating / 5.0))
                }
            }
            .frame(width: 80, height: 6)
            
            Text(String(format: "%.1f", rating))
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 32, alignment: .trailing)
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let emoji: String
    var imageName: String? = nil
    var profileImageData: Data? = nil
    var size: CGFloat = 40
    var background: Color = .orange.opacity(0.2)
    
    var body: some View {
        Group {
            // Priority: custom image data > preset image > emoji
            if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if let imageName = imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.5))
                    .frame(width: size, height: size)
                    .background(background)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Profile Avatar View (with gradient background fallback)
struct ProfileAvatarView: View {
    let emoji: String
    var imageName: String? = nil
    var profileImageData: Data? = nil
    var size: CGFloat = 100
    
    var body: some View {
        Group {
            // Priority: custom image data > preset image > emoji
            if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.5), .red.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
            } else if let imageName = imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.5), .red.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                    
                    Text(emoji)
                        .font(.system(size: size * 0.5))
                }
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Spacer()
            
            if let action = action, let onAction = onAction {
                Button(action: onAction) {
                    Text(action)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
