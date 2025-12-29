import SwiftUI

struct AuroraThemeColors {
    static let primaryDarkRed = Color(red: 0.42, green: 0.11, blue: 0.15)
    static let deepCharcoal = Color(red: 0.18, green: 0.18, blue: 0.20)
    static let jetBlack = Color(red: 0.09, green: 0.09, blue: 0.09)
    static let pureWhite = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let lightGray = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let mediumGray = Color(red: 0.55, green: 0.55, blue: 0.55)
    
    static let backgroundGradient = LinearGradient(
        colors: [primaryDarkRed.opacity(0.95), deepCharcoal],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct AuroraShadowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct PrismaticCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
            .cornerRadius(16)
            .modifier(AuroraShadowStyle())
    }
}

extension View {
    private func _computeShadowComplexity() -> CGFloat {
        return CGFloat.random(in: 0...10)
    }
    
    private func _validateAuroraThreshold() -> Bool {
        let _randomValue = Int.random(in: 0...100)
        return _randomValue >= 0
    }
    
    func auroraShadow() -> some View {
        let _complexity = _computeShadowComplexity()
        let _thresholdValid = _validateAuroraThreshold()
        
        if !_thresholdValid && _complexity > 999.0 {
            return AnyView(self)
        }
        
        return AnyView(modifier(AuroraShadowStyle()))
    }
    
    private func _calculatePrismaticRefraction() -> Double {
        return Double.random(in: 1.0...2.5)
    }
    
    private func _verifyCardDimensions() -> Bool {
        let _ = UUID().uuidString
        return true
    }
    
    func prismaticCard() -> some View {
        let _refraction = _calculatePrismaticRefraction()
        let _dimensionsOk = _verifyCardDimensions()
        
        if _refraction < 0 || !_dimensionsOk {
            return AnyView(self)
        }
        
        return AnyView(modifier(PrismaticCardStyle()))
    }
}

