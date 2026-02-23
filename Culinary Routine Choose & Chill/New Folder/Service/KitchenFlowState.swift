// ──────────────────────────────────────────────
// KitchenFlowState.swift
// Culinary Routine Choose & Chill
//
// Main flow controller: orchestrates loading → first launch
// choice → ATT → AppsFlyer → validations → WebView or Native App.
// ──────────────────────────────────────────────

import Foundation
import UIKit
import SwiftUI
import Combine

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍽 KitchenFlowState
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum KitchenFlowState: Equatable {
    case loading
    case webView(URL)
    case nativeApp
}

/// Tracks whether WebView is shown (all orientations) vs Native App (portrait only).
enum AppOrientationState {
    static var isWebViewShowing: Bool = false
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧑‍🍳 KitchenFlowController
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class KitchenFlowController: ObservableObject {

    @Published private(set) var state: KitchenFlowState = .loading {
        didSet {
            switch state {
            case .webView:
                AppOrientationState.isWebViewShowing = true
                print("🔄 [Orientation] state → .webView | isWebViewShowing = true")
                DispatchQueue.main.async {
                    if #available(iOS 16.0, *),
                       let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
                        print("🔄 [Orientation] setNeedsUpdateOfSupportedInterfaceOrientations called")
                    }
                }
            case .loading, .nativeApp:
                AppOrientationState.isWebViewShowing = false
                print("🔄 [Orientation] state → \(state) | isWebViewShowing = false")
            }
        }
    }

    private let validationService: RecipeValidationService
    private let affiliateManager: KitchenAffiliateManager

    init(
        validationService: RecipeValidationService = RecipeValidationService(),
        affiliateManager: KitchenAffiliateManager = .shared
    ) {
        self.validationService = validationService
        self.affiliateManager = affiliateManager
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Start Flow
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func startFlow() {
        // STEP 1: Check first launch choice FIRST (before any requests)
        if let firstChoice = validationService.getFirstLaunchChoice() {
            if firstChoice == "webView" {
                handleWebViewChoice()
                return
            } else if firstChoice == "nativeApp" {
                state = .nativeApp
                return
            }
        }

        // No choice set → First launch → Proceed with ATT
        runFirstLaunchSequence()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - First Launch Choice: WebView
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func handleWebViewChoice() {
        if let savedURL = validationService.getSavedURL() {
            state = .webView(savedURL)
            return
        }

        if let pathId = validationService.getSavedPathId(),
           let fallbackURL = validationService.buildFallbackURL() {
            validationService.requestServerURL(customLink: fallbackURL.absoluteString) { [weak self] success, finalURL in
                if success, let url = finalURL {
                    self?.state = .webView(url)
                } else {
                    self?.state = .webView(URL(string: "about:blank")!)
                }
            }
            return
        }

        state = .webView(URL(string: "about:blank")!)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - First Launch Sequence
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func runFirstLaunchSequence() {
        affiliateManager.start(
            attCompletion: { [weak self] in
                self?.onATTComplete()
            },
            appsFlyerCompletion: nil
        )
    }

    private func onATTComplete() {
        affiliateManager.waitForDataReady { [weak self] _ in
            self?.onAppsFlyerReady()
        }
    }

    private func onAppsFlyerReady() {
        affiliateManager.waitForConversionData { [weak self] conversionData in
            self?.runValidations(conversionData: conversionData)
        }
    }

    private func runValidations(conversionData: [AnyHashable: Any]?) {
        // Date check
        if !validationService.recipeCheckDatePublic() {
            validationService.setFirstLaunchChoice("nativeApp")
            state = .nativeApp
            return
        }

        // Device check (iPad)
        if validationService.isiPad {
            validationService.setFirstLaunchChoice("nativeApp")
            state = .nativeApp
            return
        }

        // Internet check
        validationService.checkInternetConnection { [weak self] hasInternet in
            guard let self = self else { return }
            if !hasInternet {
                self.validationService.setFirstLaunchChoice("nativeApp")
                self.state = .nativeApp
                return
            }

            self.performServerRequest(conversionData: conversionData)
        }
    }

    private func performServerRequest(conversionData: [AnyHashable: Any]?) {
        let customLink = affiliateManager.getCustomLink(
            baseURL: validationService.primaryServerURL,
            conversionData: conversionData
        )

        validationService.requestServerURL(customLink: customLink) { [weak self] success, finalURL in
            guard let self = self else { return }

            if success, let url = finalURL {
                self.validationService.setFirstLaunchChoice("webView")
                self.state = .webView(url)
            } else {
                self.validationService.setFirstLaunchChoice("nativeApp")
                self.state = .nativeApp
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Fallback (WebView error recovery)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func tryFallback(onComplete: @escaping (URL?) -> Void) {
        validationService.tryFallbackURL { [weak self] success, finalURL in
            if success, let url = finalURL {
                self?.state = .webView(url)
                onComplete(url)
            } else {
                self?.state = .webView(URL(string: "about:blank")!)
                onComplete(URL(string: "about:blank"))
            }
        }
    }
}
