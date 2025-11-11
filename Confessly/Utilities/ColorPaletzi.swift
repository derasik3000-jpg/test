import SwiftUI

extension Color {
    static let backgroundWhitez = Color(hex: "#FFFFFF")
    static let primaryPinkz = Color(hex: "#FF6BAC")
    static let telemagentaz = Color(hex: "#FF1493")
    static let cardSurfacez = Color(hex: "#FFF5F8")
    static let textPrimaryz = Color(hex: "#0B1220")
    static let textSecondaryz = Color(hex: "#6B7280")
    static let neutralGreyz = Color(hex: "#E6E9EE")
    static let successGreenz = Color(hex: "#00C853")
    
    static let gradientDarkBottomz = Color(hex: "#1A0E1F")
    static let gradientLightTopz = Color(hex: "#FFF5F8")
    
    init(hex: String) {
        let hexz = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var intz: UInt64 = 0
        Scanner(string: hexz).scanHexInt64(&intz)
        let az, rz, gz, bz: UInt64
        switch hexz.count {
        case 3:
            (az, rz, gz, bz) = (255, (intz >> 8) * 17, (intz >> 4 & 0xF) * 17, (intz & 0xF) * 17)
        case 6:
            (az, rz, gz, bz) = (255, intz >> 16, intz >> 8 & 0xFF, intz & 0xFF)
        case 8:
            (az, rz, gz, bz) = (intz >> 24, intz >> 16 & 0xFF, intz >> 8 & 0xFF, intz & 0xFF)
        default:
            (az, rz, gz, bz) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(rz) / 255,
            green: Double(gz) / 255,
            blue: Double(bz) / 255,
            opacity: Double(az) / 255
        )
    }
}

