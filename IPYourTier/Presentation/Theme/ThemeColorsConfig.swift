import SwiftUI

public struct ThemeColorsConfig {
    // Основные цвета
    public static let backgroundDeep = Color(hex: "1C2E3A")      // Глубокий тёмно-синий (основной фон)
    public static let backgroundCard = Color(hex: "243B4A")      // Чуть светлее для карточек
    
    // Акцентные цвета
    public static let accentBright = Color(hex: "00D9C4")        // Бирюзовый (основной акцент)
    public static let accentWarm = Color(hex: "FF7B5A")          // Коралловый (тёплый акцент)
    
    // Текст и нейтральные
    public static let primaryLight = Color(hex: "F0F6F8")        // Светлый для текста
    public static let neutralAxis = Color(hex: "6A8A99")         // Приглушённый серо-голубой
    public static let neutralMuted = Color(hex: "3D5463")        // Тёмный нейтральный
    
    // Opacity для уровней риска
    public static let lowRiskOpacity: Double = 0.55
    public static let mediumRiskOpacity: Double = 0.70
    public static let highRiskOpacity: Double = 0.85
    public static let redFlagOpacity: Double = 1.0
    
    public static func riskColor(for level: RiskLevel) -> Color {
        return accentBright.opacity(level.opacity)
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension RiskLevel {
    var opacity: Double {
        switch self {
        case .low: return ThemeColorsConfig.lowRiskOpacity
        case .medium: return ThemeColorsConfig.mediumRiskOpacity
        case .high: return ThemeColorsConfig.highRiskOpacity
        case .red: return ThemeColorsConfig.redFlagOpacity
        }
    }
}
