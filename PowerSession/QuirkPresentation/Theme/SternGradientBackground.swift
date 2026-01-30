import SwiftUI

public struct SternGradientBackground: View {
    public init() {}
    
    public var body: some View {
        LinearGradient(
            colors: [
                VexColorPalette.murkyGradientEnd,
                VexColorPalette.murkyGradientStart
            ],
            startPoint: .bottom,
            endPoint: .top
        )
        .ignoresSafeArea()
    }
}

