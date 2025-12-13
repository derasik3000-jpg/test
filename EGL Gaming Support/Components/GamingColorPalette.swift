import SwiftUI

struct GamingColorPalette {
    // Primary colors - Purple gradient
    static let primaryPurple = Color(hex: "#6A00FF") // Deep purple
    static let primaryMagenta = Color(hex: "#B100FF") // Bright magenta
    
    // Secondary color - Cyan
    static let secondaryCyan = Color(hex: "#00E5FF") // Bright cyan
    
    // Background colors
    static let backgroundDark = Color(hex: "#0A0A0A") // Main dark background
    static let backgroundLight = Color(hex: "#1B1B1B") // Lighter dark background
    
    // White accents
    static let pureWhite = Color(hex: "#FFFFFF")
    
    // Legacy color mappings for compatibility
    static let primaryBlue = primaryPurple // Mapped to new primary
    static let secondaryOrange = primaryMagenta // Mapped to magenta
    static let neonPink = primaryMagenta // Mapped to magenta
    static let neonPurple = primaryPurple // Mapped to primary purple
    static let neonGreen = secondaryCyan // Mapped to cyan
    static let lightBlue = secondaryCyan // Mapped to cyan
    
    // Gradient colors for backgrounds
    static let gradientTop = Color(hex: "#1B1B1B") // Lighter background
    static let gradientBottom = Color(hex: "#0A0A0A") // Main dark
    static let lightBackground = backgroundDark
    
    // Text colors
    static let textPrimary = Color(hex: "#FFFFFF") // White text
    static let textSecondary = Color(hex: "#A0A0A0") // Light gray
    static let textOnAccent = Color(hex: "#FFFFFF")
    
    // Card backgrounds
    static let cardBackground = Color(hex: "#1B1B1B") // Lighter dark
    static let overlayBackground = Color(hex: "#1B1B1B").opacity(0.95)
    
    // Gradient helpers
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryPurple, primaryMagenta]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryPurple, primaryMagenta]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryMagenta, primaryPurple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var highlightGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryMagenta.opacity(0.8), primaryPurple.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
