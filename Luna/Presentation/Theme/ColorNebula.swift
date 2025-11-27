import SwiftUI

extension Color {
    // Светлая тема (по умолчанию)
    static let nebulaBlossom = Color(hex: "#FFB6C1")
    static let lavenderMist = Color(hex: "#E6E6FA")
    static let pureEssence = Color(hex: "#FFFFFF")
    static let shadowText = Color(hex: "#404040")
    static let blushWhisper = Color(hex: "#F8E0F7")
    
    // Тёмная тема - новая палитра
    static let nightBloom = Color(hex: "#9D84B7")        // Мягкий фиолетовый
    static let twilightVeil = Color(hex: "#5B4B8A")      // Глубокий сине-фиолетовый
    static let midnightCanvas = Color(hex: "#1A1625")    // Очень тёмный фиолетово-синий
    static let moonlitText = Color(hex: "#E8D4F2")       // Светло-лавандовый текст
    static let stardustGlow = Color(hex: "#4A3B5C")      // Приглушённый фиолетовый
    static let dreamyRose = Color(hex: "#D4A5C4")        // Пыльная роза
    
    // Адаптивные цвета
    static func adaptiveAccent(_ isDark: Bool) -> Color {
        isDark ? nightBloom : nebulaBlossom
    }
    
    static func adaptiveBackground(_ isDark: Bool) -> Color {
        isDark ? midnightCanvas : pureEssence
    }
    
    static func adaptiveText(_ isDark: Bool) -> Color {
        isDark ? moonlitText : shadowText
    }
    
    static func adaptiveSecondary(_ isDark: Bool) -> Color {
        isDark ? stardustGlow : lavenderMist
    }
    
    static func adaptiveCard(_ isDark: Bool) -> Color {
        isDark ? stardustGlow.opacity(0.6) : pureEssence.opacity(0.7)
    }
    
    init(hex: String) {
        let hexValue = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var intValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&intValue)
        
        let red = Double((intValue & 0xFF0000) >> 16) / 255.0
        let green = Double((intValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(intValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

extension LinearGradient {
    static func celestialBackdrop(isDark: Bool) -> LinearGradient {
        if isDark {
            // Тёмная тема: от глубокого фиолетового к тёмно-синему
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.twilightVeil.opacity(0.8),
                    Color.midnightCanvas.opacity(0.95),
                    Color.midnightCanvas
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            // Светлая тема: классический градиент
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.pureEssence,
                    Color.lavenderMist.opacity(0.6),
                    Color.nebulaBlossom.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // Для совместимости со старым кодом
    static var celestialBackdrop: LinearGradient {
        let isDark = UserDefaults.standard.bool(forKey: "nightModeActivated")
        return celestialBackdrop(isDark: isDark)
    }
}

