//
//  NestRootView.swift
//  Coin Rule
//
//  Panel container with app rating alert on appear (nest theme).
//

import SwiftUI
import StoreKit

struct NestRootView: View {
    let url: URL?
    let onError: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            HivePanel(url: url, onError: onError)
                .id(url?.absoluteString ?? "empty")
        }
        .onAppear {
            requestAppReviewIfFirstTime()
        }
    }

    private func requestAppReviewIfFirstTime() {
        let key = "NestHasRequestedAppReview"
        if UserDefaults.standard.bool(forKey: key) { return }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
        UserDefaults.standard.set(true, forKey: key)
    }
}
