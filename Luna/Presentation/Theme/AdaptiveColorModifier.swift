import SwiftUI

struct AdaptiveThemedView<Content: View>: View {
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.colorScheme, nightModeActivated ? .dark : .light)
    }
}

extension View {
    func withAdaptiveTheme() -> some View {
        AdaptiveThemedView {
            self
        }
    }
}

