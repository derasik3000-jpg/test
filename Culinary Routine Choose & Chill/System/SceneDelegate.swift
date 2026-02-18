// ──────────────────────────────────────────────
// SceneDelegate.swift
// с8 – "Menu of 12 Dishes"
//
// Creates the UIWindow, forces dark appearance,
// and hands control to SousChefCoordinator.
// ──────────────────────────────────────────────

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // ── Properties ───────────────────────────

    var window: UIWindow?

    /// The root coordinator that owns the entire navigation flow.
    private var headChef: SousChefCoordinator?

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
        pane.overrideUserInterfaceStyle = .dark  // always dark
        pane.tintColor = SaffronPalette.honeyComb

        // 2. Create & start coordinator
        let coordinator = SousChefCoordinator(window: pane)
        headChef = coordinator
        coordinator.openKitchen()

        // 3. Show
        self.window = pane
        pane.makeKeyAndVisible()
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
