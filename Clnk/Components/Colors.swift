//
//  Colors.swift
//  Clnk
//
//  Design System - Programmatically controlled colors
//  Edit the hex values here to tweak the entire app's color scheme
//

import SwiftUI

// MARK: - Color Extension from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Design System Colors
struct ClnkColors {
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Primary Teals
    // ═══════════════════════════════════════════════════════════════════
    
    struct Primary {
        static let shade900 = Color(hex: "022D2B")
        static let shade800 = Color(hex: "035552")
        static let shade700 = Color(hex: "0B443D")
        static let shade600 = Color(hex: "0A5D56")
        static let shade500 = Color(hex: "0E6E66")
        static let shade400 = Color(hex: "1A8A82")
        static let shade300 = Color(hex: "3AA69E")
        static let shade200 = Color(hex: "6DC4BD")
        static let shade100 = Color(hex: "A8DDD8")
        static let shade50  = Color(hex: "E0F4F2")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Accent Cyans
    // ═══════════════════════════════════════════════════════════════════
    
    struct Accent {
        static let shade700 = Color(hex: "066561")
        static let shade600 = Color(hex: "09817B")
        static let shade500 = Color(hex: "0C7F80")
        static let shade400 = Color(hex: "14A3A3")
        static let shade300 = Color(hex: "2DD4D4")
        static let shade200 = Color(hex: "67E8E8")
        static let shade100 = Color(hex: "A5F3F3")
        static let shade50  = Color(hex: "D9FAFA")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Sage / Neutral Greens
    // ═══════════════════════════════════════════════════════════════════
    
    struct Sage {
        static let shade700 = Color(hex: "5A8A7D")
        static let shade600 = Color(hex: "72A696")
        static let shade500 = Color(hex: "A1CAC0")
        static let shade400 = Color(hex: "B8D9D0")
        static let shade300 = Color(hex: "CEEAE3")
        static let shade200 = Color(hex: "E2F2ED")
        static let shade100 = Color(hex: "F0F8F5")
        static let shade50  = Color(hex: "F4F7E8")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Highlight Accents - Gold (Warm)
    // ═══════════════════════════════════════════════════════════════════
    
    struct Gold {
        static let shade600 = Color(hex: "B8860B")
        static let shade500 = Color(hex: "D4A017")
        static let shade400 = Color(hex: "F0C045")
        static let shade300 = Color(hex: "F7D777")
        static let shade200 = Color(hex: "FBEAAE")
        static let shade100 = Color(hex: "FDF6E3")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Highlight Accents - Coral (Warm)
    // ═══════════════════════════════════════════════════════════════════
    
    struct Coral {
        static let shade600 = Color(hex: "C75C3A")
        static let shade500 = Color(hex: "E07452")
        static let shade400 = Color(hex: "F09D85")
        static let shade300 = Color(hex: "F7C4B5")
        static let shade200 = Color(hex: "FCDDD4")
        static let shade100 = Color(hex: "FEF0EC")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Highlight Accents - Electric
    // ═══════════════════════════════════════════════════════════════════
    
    struct Electric {
        static let shade600 = Color(hex: "0891B2")
        static let shade500 = Color(hex: "06B6D4")
        static let shade400 = Color(hex: "22D3EE")
        static let shade300 = Color(hex: "67E8F9")
        static let shade200 = Color(hex: "A5F3FC")
        static let shade100 = Color(hex: "CFFAFE")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Semantic Colors
    // ═══════════════════════════════════════════════════════════════════
    
    struct Success {
        static let shade600 = Color(hex: "0D7A5F")
        static let shade500 = Color(hex: "10B981")
        static let shade400 = Color(hex: "34D399")
        static let shade100 = Color(hex: "D1FAE5")
    }
    
    struct Warning {
        static let shade600 = Color(hex: "B45309")
        static let shade500 = Color(hex: "F59E0B")
        static let shade400 = Color(hex: "FBBF24")
        static let shade100 = Color(hex: "FEF3C7")
    }
    
    struct Error {
        static let shade600 = Color(hex: "B91C1C")
        static let shade500 = Color(hex: "EF4444")
        static let shade400 = Color(hex: "F87171")
        static let shade100 = Color(hex: "FEE2E2")
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Neutrals
    // ═══════════════════════════════════════════════════════════════════
    
    struct Neutral {
        static let shade900 = Color(hex: "1A1F1E")
        static let shade800 = Color(hex: "2D3533")
        static let shade700 = Color(hex: "404A47")
        static let shade600 = Color(hex: "5A6662")
        static let shade500 = Color(hex: "75827D")
        static let shade400 = Color(hex: "9CA8A3")
        static let shade300 = Color(hex: "C4CCC8")
        static let shade200 = Color(hex: "E2E7E5")
        static let shade100 = Color(hex: "F1F4F3")
        static let shade50  = Color(hex: "F8FAF9")
    }
}

// MARK: - Semantic Aliases (for easy use throughout the app)
extension ClnkColors {
    
    // Backgrounds
    static var background: Color { Sage.shade50 }
    static var backgroundSecondary: Color { Sage.shade100 }
    static var backgroundTertiary: Color { Sage.shade200 }
    static var backgroundDark: Color { Primary.shade800 }
    static var backgroundDarkSecondary: Color { Primary.shade700 }
    
    // Text
    static var textPrimary: Color { Primary.shade800 }
    static var textSecondary: Color { Neutral.shade600 }
    static var textTertiary: Color { Neutral.shade500 }
    static var textOnDark: Color { Sage.shade50 }
    static var textMuted: Color { Sage.shade600 }
    
    // Interactive
    static var interactive: Color { Accent.shade600 }
    static var interactiveHover: Color { Accent.shade500 }
    static var interactivePressed: Color { Accent.shade700 }
    
    // Buttons
    static var buttonPrimary: Color { Primary.shade800 }
    static var buttonPrimaryHover: Color { Primary.shade700 }
    static var buttonAccent: Color { Accent.shade500 }
    static var buttonGold: Color { Gold.shade500 }
    static var buttonCoral: Color { Coral.shade500 }
    static var buttonElectric: Color { Electric.shade500 }
    static var buttonGhost: Color { Sage.shade300 }
    
    // Cards & Surfaces
    static var cardBackground: Color { .white }
    static var cardBackgroundElevated: Color { Sage.shade100 }
    static var cardBorder: Color { Sage.shade300 }
    
    // Dividers & Borders
    static var divider: Color { Sage.shade300 }
    static var border: Color { Sage.shade400 }
    static var borderFocused: Color { Accent.shade500 }
    
    // Status
    static var success: Color { Success.shade500 }
    static var warning: Color { Warning.shade500 }
    static var error: Color { Error.shade500 }
    static var info: Color { Electric.shade500 }
    
    // Gradients (as tuple pairs for LinearGradient)
    static var gradientPrimary: (Color, Color) { (Primary.shade800, Primary.shade600) }
    static var gradientAccent: (Color, Color) { (Accent.shade600, Accent.shade400) }
    static var gradientWarm: (Color, Color) { (Coral.shade600, Gold.shade500) }
    static var gradientElectric: (Color, Color) { (Primary.shade700, Electric.shade500) }
    static var gradientNature: (Color, Color) { (Primary.shade800, Sage.shade500) }
    
    // Stats/Highlights
    static var statValue: Color { Gold.shade400 }
}

// MARK: - Convenience Color Extension
extension Color {
    static let clnk = ClnkColors.self
}

// MARK: - Gradient Helpers
extension LinearGradient {
    static var clnkPrimary: LinearGradient {
        LinearGradient(
            colors: [ClnkColors.Primary.shade800, ClnkColors.Primary.shade600],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var clnkAccent: LinearGradient {
        LinearGradient(
            colors: [ClnkColors.Accent.shade600, ClnkColors.Accent.shade400],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var clnkWarm: LinearGradient {
        LinearGradient(
            colors: [ClnkColors.Coral.shade600, ClnkColors.Gold.shade500],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var clnkElectric: LinearGradient {
        LinearGradient(
            colors: [ClnkColors.Primary.shade700, ClnkColors.Electric.shade500],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var clnkStats: LinearGradient {
        LinearGradient(
            colors: [ClnkColors.Primary.shade800, ClnkColors.Accent.shade600],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
