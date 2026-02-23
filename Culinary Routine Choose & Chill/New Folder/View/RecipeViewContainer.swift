// ──────────────────────────────────────────────
// RecipeViewContainer.swift
// Culinary Routine Choose & Chill
//
// WebView container with app rating alert shown
// immediately when WebView appears.
// ──────────────────────────────────────────────

import SwiftUI
import StoreKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍽 RecipeViewContainer
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct RecipeViewContainer: View {

    let url: URL
    var onError: (() -> Void)?
    var on404Detected: (() -> Void)?

    var body: some View {
        RecipeViewPanel(
            url: url,
            onError: onError,
            on404Detected: on404Detected
        )
        .id(url.absoluteString)
        .onAppear {
            requestAppReviewOnce()
        }
    }

    private func requestAppReviewOnce() {
        guard !FrostBox.hasShownWebViewRating else { return }
        FrostBox.hasShownWebViewRating = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
