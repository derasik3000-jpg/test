import SwiftUI

// MARK: - Beautiful App Background
struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            // Base dark background
            Color.appBackground.ignoresSafeArea()
            
            // Subtle gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appAccentOrange.opacity(0.08),
                            Color.appAccentOrange.opacity(0)
                        ],
                        center: .topTrailing,
                        startRadius: 50,
                        endRadius: 300
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: 150, y: -200)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appAccentYellow.opacity(0.06),
                            Color.appAccentYellow.opacity(0)
                        ],
                        center: .bottomLeading,
                        startRadius: 50,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -150, y: 300)
                .blur(radius: 50)
            
            // Subtle noise texture overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.02),
                            Color.clear,
                            Color.white.opacity(0.01)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()
        }
    }
}

