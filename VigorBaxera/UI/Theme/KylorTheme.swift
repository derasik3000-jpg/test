import SwiftUI

public struct KylorTheme {
    public static let bgStart = Color(red: 0xFF/255, green: 0x7A/255, blue: 0x21/255)
    public static let bgEnd = Color(red: 0xFF/255, green: 0x6B/255, blue: 0x8A/255)
    public static let bgCard = Color.white.opacity(0.10)
    
    public static let accentBase = Color(red: 0x7A/255, green: 0x0C/255, blue: 0x16/255)
    public static let accentOn = Color.white
    public static let accentSubtle = Color(red: 0x7A/255, green: 0x0C/255, blue: 0x16/255).opacity(0.18)
    
    public static let surface = Color(red: 0xFE/255, green: 0xFE/255, blue: 0xFE/255)
    public static let textOnSurface = Color(red: 0x0F/255, green: 0x10/255, blue: 0x12/255)
    
    public static let timerStroke = accentBase
    public static let timerTrack = Color.white.opacity(0.28)
    
    public static let chartStroke = Color(red: 0x7A/255, green: 0x0C/255, blue: 0x16/255).opacity(0.90)
    public static let chartFill = Color(red: 0x7A/255, green: 0x0C/255, blue: 0x16/255).opacity(0.55)
    public static let chartSoft = Color.white.opacity(0.85)
    public static let chartGrid = Color.white.opacity(0.22)
    public static let chartWarn = Color(red: 0xFF/255, green: 0xCD/255, blue: 0x00/255).opacity(0.90)
    
    public static var qytexGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [bgEnd, bgStart]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    public static let cornerRadius: CGFloat = 16
    public static let buttonCornerRadius: CGFloat = 20
    public static let minTouchSize: CGFloat = 44
}

public struct KylorGradientBackground: ViewModifier {
    public func body(content: Content) -> some View {
        ZStack {
            KylorTheme.qytexGradient
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    public func gyrexApplyBackground() -> some View {
        self.modifier(KylorGradientBackground())
    }
}

