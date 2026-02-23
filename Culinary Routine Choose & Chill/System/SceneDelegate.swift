// ──────────────────────────────────────────────
// SceneDelegate.swift
// Culinary Routine Choose & Chill
//
// Creates the UIWindow, forces dark appearance.
// WebView flow: KitchenRootView → WebView or Native App.
// Native App: SousChefCoordinator (onboarding / main tabs).
// ──────────────────────────────────────────────

import UIKit
import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - KitchenHostingController
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Hosting controller that respects AppOrientationState for rotation.
final class KitchenHostingController<Content: View>: UIHostingController<Content> {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        AppOrientationState.isWebViewShowing
            ? [.portrait, .landscapeLeft, .landscapeRight]
            : .portrait
    }

    override var shouldAutorotate: Bool {
        AppOrientationState.isWebViewShowing
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - SceneDelegate
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // ── Properties ───────────────────────────

    var window: UIWindow?

    /// Flow controller for WebView / Native App decision.
    private var flowController: KitchenFlowController?

    /// Coordinator for native app (onboarding, main tabs).
    private var headChef: SousChefCoordinator?

    /// Prevents double transition when onAppear fires multiple times.
    private var hasTransitionedToNative = false

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Scene Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // 1. Create window
        let pane = UIWindow(windowScene: windowScene)
        pane.overrideUserInterfaceStyle = .dark
        pane.tintColor = SaffronPalette.honeyComb
        pane.backgroundColor = .clear

        // 2. WebView flow: KitchenRootView first
        let controller = KitchenFlowController()
        flowController = controller

        let rootView = KitchenRootView(
            flowController: controller,
            onNativeAppRequested: { [weak self] in
                self?.transitionToNativeApp()
            }
        )

        let hosting = KitchenHostingController(rootView: rootView)
        hosting.view.backgroundColor = .clear
        pane.rootViewController = hosting

        // 3. Start flow (ATT → AppsFlyer → validations)
        controller.startFlow()

        // 4. Show
        self.window = pane
        pane.makeKeyAndVisible()
    }

    /// Transition to native app (onboarding or main tabs).
    private func transitionToNativeApp() {
        guard !hasTransitionedToNative else { return }
        guard let pane = window else { return }

        hasTransitionedToNative = true
        print("🔄 [Orientation] transitionToNativeApp | setting isWebViewShowing = false")
        AppOrientationState.isWebViewShowing = false
        let coordinator = SousChefCoordinator(window: pane)
        headChef = coordinator
        coordinator.openKitchen(skipSplash: true)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - State Transitions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Could refresh week plan if needed
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Nothing special
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CellarVault.shared.forceServe()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Could check if week rolled over
    }
}
