import SwiftUI

struct GamingGradientBackgroundView: View {
    var body: some View {
        ZStack {
            // Main dark background
            GamingColorPalette.backgroundDark
            
            // Primary gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    GamingColorPalette.backgroundLight,
                    GamingColorPalette.backgroundDark
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Purple accent glow (top-left)
            RadialGradient(
                gradient: Gradient(colors: [
                    GamingColorPalette.primaryPurple.opacity(0.15),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 50,
                endRadius: 350
            )
            
            // Magenta accent glow (bottom-right)
            RadialGradient(
                gradient: Gradient(colors: [
                    GamingColorPalette.primaryMagenta.opacity(0.1),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 80,
                endRadius: 400
            )
            
            // Cyan accent glow (center-bottom)
            RadialGradient(
                gradient: Gradient(colors: [
                    GamingColorPalette.secondaryCyan.opacity(0.05),
                    Color.clear
                ]),
                center: .bottom,
                startRadius: 100,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

struct GamingGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            GamingGradientBackgroundView()
            content
        }
    }
}

extension View {
    func gamingGradientBackground() -> some View {
        modifier(GamingGradientBackgroundModifier())
    }
}
