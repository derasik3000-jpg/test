import UIKit

struct PqColors {
    static let deepIndigoBase = UIColor(hex: "#002C71")
    static let brightTurquoiseAccent = UIColor(hex: "#0EBAEF")
    static let pureWhitePrimary = UIColor(hex: "#FEFEFE")
    
    static let textPrimaryLight = UIColor(hex: "#F5FAFF")
    static let textSecondaryFaded = UIColor(hex: "#F5FAFF", alpha: 0.72)
    static let dividerSubtle = UIColor(hex: "#F5FAFF", alpha: 0.12)
    
    static let successLeafGreen = UIColor(hex: "#1E8E3E")
    static let warningYellow = UIColor(hex: "#F7B500")
    static let errorTrafficRed = UIColor(hex: "#D0021B")
    
    static let pressedOverlay = UIColor(hex: "#0EBAEF", alpha: 0.14)
    static let disabledOverlay = UIColor(hex: "#FEFEFE", alpha: 0.48)
    
    static let checkboxOffBorder = UIColor(hex: "#FFFFFF", alpha: 0.36)
    static let sleepWindowGlow = UIColor(hex: "#0EBAEF", alpha: 0.8)
    static let afterWindowBorder = UIColor(hex: "#F5FAFF", alpha: 0.28)
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

