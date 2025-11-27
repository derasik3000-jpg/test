import SwiftUI

struct GradientBackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient.celestialBackdrop
                .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func celestialBackdrop() -> some View {
        modifier(GradientBackdropModifier())
    }
}

