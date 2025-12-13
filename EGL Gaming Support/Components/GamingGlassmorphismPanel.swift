import SwiftUI

struct GamingGlassmorphismPanel<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .contentShape(Rectangle())
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(GamingColorPalette.cardBackground)
                    
                    // Purple-magenta gradient border glow
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    GamingColorPalette.primaryPurple.opacity(0.6),
                                    GamingColorPalette.primaryMagenta.opacity(0.5),
                                    GamingColorPalette.secondaryCyan.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .blur(radius: 0.5)
                }
                .shadow(color: GamingColorPalette.primaryPurple.opacity(0.3), radius: 20, x: 0, y: 10)
                .shadow(color: GamingColorPalette.primaryMagenta.opacity(0.2), radius: 15, x: 0, y: 5)
                .allowsHitTesting(false)
            )
    }
}

struct GamingGlassmorphismCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(GamingColorPalette.cardBackground)
                    
                    // Purple-magenta gradient border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    GamingColorPalette.primaryPurple.opacity(0.5),
                                    GamingColorPalette.primaryMagenta.opacity(0.4),
                                    GamingColorPalette.primaryPurple.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 0.3)
                }
                .shadow(color: GamingColorPalette.primaryPurple.opacity(0.2), radius: 12, x: 0, y: 6)
                .shadow(color: GamingColorPalette.primaryMagenta.opacity(0.1), radius: 8, x: 0, y: 3)
                .allowsHitTesting(false)
            )
    }
}
