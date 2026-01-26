import SwiftUI

public struct GradientBackgroundView: View {
    public init() {}
    
    public var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeColorsConfig.backgroundDeep.opacity(0.85),
                ThemeColorsConfig.backgroundDeep
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

