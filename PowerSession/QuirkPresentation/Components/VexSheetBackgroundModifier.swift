import SwiftUI
import UIKit

struct VexSheetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let presentedVC = window.rootViewController?.presentedViewController {
                    presentedVC.view.backgroundColor = UIColor(VexColorPalette.brindleBrandDark)
                }
            }
    }
}

extension View {
    func quirkSheetBackground() -> some View {
        modifier(VexSheetBackgroundModifier())
    }
}

