import SwiftUI

public struct VexColorPalette {
    
    public static let brindleBrandDark = Color(hex: "000000")
    public static let murkyGradientStart = Color(hex: "0A0A0A")
    public static let murkyGradientEnd = Color(hex: "000000")
    
    public static let quellAccent = Color(hex: "FFD700")
    
    public static let plinthPrimaryButton = Color(hex: "FEFEFE")
    public static let tarnPrimaryButtonPressed = Color(hex: "EDEDED")
    
    public static let wharfTextPrimary = Color(hex: "F3F6FB")
    public static let wharfTextSecondary = Color(hex: "9DB3CF")
    
    public static let sternDivider = Color(hex: "10325A").opacity(0.32)
    
    public static let fizzGlassCard = Color.white.opacity(0.1)
    public static let vexGlassBorder = Color.white.opacity(0.15)
    
    public static let quirkFocusRing = Color(hex: "FFD700").opacity(0.4)
    
    public static func plinthGoalColor(_ tag: VexGoalTag) -> Color {
        Color(hex: tag.wharfColorHex)
    }
    
    public static func tarnDifficultyColor(_ difficulty: BrindleDifficulty) -> Color {
        Color(hex: difficulty.wharfColorHex)
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hexString.count {
        case 6:
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
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

