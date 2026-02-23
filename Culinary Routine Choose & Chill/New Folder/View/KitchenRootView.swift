// ──────────────────────────────────────────────
// KitchenRootView.swift
// Culinary Routine Choose & Chill
//
// Root view orchestrating the WebView flow:
// Loading → WebView or Native App.
// ──────────────────────────────────────────────

import SwiftUI
import UIKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍽 KitchenRootView
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct KitchenRootView: View {

    @ObservedObject var flowController: KitchenFlowController
    var onNativeAppRequested: () -> Void

    var body: some View {
        Group {
            switch flowController.state {
            case .loading:
                KitchenSplashScreenView()
                    .ignoresSafeArea(.all, edges: .all)

            case .webView(let url):
                RecipeViewContainer(
                    url: url,
                    onError: handleWebViewError,
                    on404Detected: handleWebViewError
                )
                .id(url.absoluteString)
                .onAppear { print("🔄 [Orientation] KitchenRootView .webView appeared | url=\(url)") }

            case .nativeApp:
                Color.clear
                    .onAppear { onNativeAppRequested() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: flowController.state)
    }

    private func handleWebViewError() {
        flowController.tryFallback { _ in }
    }
}
