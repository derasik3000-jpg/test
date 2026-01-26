import Foundation
import SwiftUI

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

// MARK: - Dark Theme Colors
extension Color {
    // Акцентные цвета (жёлтый/оранжевый)
    static let appAccentYellow = Color(hex: "#FFD60A")      // Яркий жёлтый
    static let appAccentOrange = Color(hex: "#FF9F0A")      // Насыщенный оранжевый
    static let appAccentGold = Color(hex: "#FFCC00")        // Золотистый
    
    // Фоны
    static let appBackground = Color(hex: "#000000")        // Основной фон (чёрный)
    static let appBackgroundSecondary = Color(hex: "#1C1C1E") // Вторичный фон
    static let appCardBackground = Color(hex: "#2C2C2E")    // Фон карточек
    static let appCardBackgroundElevated = Color(hex: "#3A3A3C") // Приподнятые элементы
    
    // Текст
    static let appTextPrimary = Color(hex: "#FFFFFF")       // Основной текст
    static let appTextSecondary = Color(hex: "#8E8E93")     // Вторичный текст
    static let appTextTertiary = Color(hex: "#636366")      // Третичный текст
    static let appDarkText = Color(hex: "#FFFFFF")          // Тёмный текст (для светлых фонов)
    
    // Дополнительные цвета для визуализаций
    static let appAquaCyan = Color(hex: "#5AC8FA")          // Голубой (для графиков)
    static let appDeepSkyBlue = Color(hex: "#007AFF")       // Синий (для графиков)
    
    // Дополнительные
    static let appDivider = Color(hex: "#38383A")           // Разделители
    static let appSuccess = Color(hex: "#30D158")           // Успех (зелёный)
    static let appError = Color(hex: "#FF453A")             // Ошибка (красный)
}

// MARK: - Gradients
extension LinearGradient {
    static let appAccentGradient = LinearGradient(
        colors: [Color.appAccentYellow, Color.appAccentOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
