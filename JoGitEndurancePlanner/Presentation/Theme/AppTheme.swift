import SwiftUI

struct AppTheme {
    // MARK: - Base Colors
    static let backgroundDeep = Color(hex: "#0A0A0C")
    static let backgroundElevated = Color(hex: "#141418")
    static let surfaceDark = Color(hex: "#1C1C22")
    
    // MARK: - Gold Accents
    static let goldPrimary = Color(hex: "#D4A847")
    static let goldLight = Color(hex: "#F0D78C")
    static let goldDark = Color(hex: "#A67C2E")
    
    // MARK: - Brand Colors
    static let accentBright = goldPrimary  // Alias for gold primary
    static let brandDeep = backgroundDeep  // Alias for background deep
    static let surfaceWhite = Color.white  // White surface
    
    // MARK: - Text
    static let textPrimary = Color(hex: "#F5F5F7")
    static let textSecondary = Color(hex: "#8E8E93")
    static let textMuted = Color(hex: "#5A5A5E")
    
    // MARK: - Utility
    static let dividerTint = Color(hex: "#2C2C30")
    static let glassCardBackground = Color.white.opacity(0.06)
    
    // MARK: - Status
    static let successGreen = Color(hex: "#34C759")
    static let warnYellow = Color(hex: "#FFD60A")
    static let dangerRed = Color(hex: "#FF453A")
    
    // MARK: - Gradients
    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundDeep, backgroundElevated],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldDark, goldPrimary, goldLight],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
    
    static func cardGradient(opacity: Double = 0.08) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(opacity * 0.5),
                Color.white.opacity(opacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var goldShimmer: LinearGradient {
        LinearGradient(
            colors: [goldDark, goldPrimary, goldLight, goldPrimary, goldDark],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
