import SwiftUI

struct ColorTheme {
    
    struct Background {
        static let primaryStart = Color(hex: "F26A21")
        static let primaryEnd = Color(hex: "E6A1B0")
        static let raised = Color.white.opacity(0.06)
        static let sunken = Color.black.opacity(0.18)
    }
    
    struct Accent {
        static let accent900 = Color(hex: "4C050B")
        static let accent700 = Color(hex: "680A14")
        static let accent500 = Color(hex: "8A0C19")
        static let accent300 = Color(hex: "B03A45")
    }
    
    struct Button {
        static let fill = Color(hex: "FFFFFF")
        static let text = Color(hex: "1A1A1A")
    }
    
    struct Text {
        static let primary = Color(hex: "1A1A1A")
        static let inverse = Color(hex: "FDF7F3")
        static let secondary = Color(hex: "4E4E4E")
        static let secondaryInverse = Color(hex: "F5D7CF")
    }
    
    struct Border {
        static let soft = Color.black.opacity(0.08)
        static let strong = Color.black.opacity(0.18)
    }
    
    struct Balance {
        static let ok = Color(hex: "2ECC71")
        static let medium = Color(hex: "FF9F0A")
        static let bad = Color(hex: "8A0C19")
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

