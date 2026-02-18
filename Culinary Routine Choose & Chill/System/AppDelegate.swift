// ──────────────────────────────────────────────
// AppDelegate.swift
// с8 – "Menu of 12 Dishes"
//
// Minimal entry point. Sets global appearance
// tokens and bootstraps the persistence layer.
// ──────────────────────────────────────────────

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Launch
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 1. Touch persistence so the file is ready
        _ = CellarVault.shared

        // 2. Track app opens for gamification
        FrostBox.incrementOpenCount()

        // 3. Apply global appearance
        seasonAppearance()

        return true
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Scene Configuration
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let cfg = UISceneConfiguration(
            name: "BistroScene",
            sessionRole: connectingSceneSession.role
        )
        cfg.delegateClass = SceneDelegate.self
        return cfg
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Background Save
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func applicationDidEnterBackground(_ application: UIApplication) {
        CellarVault.shared.forceServe()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CellarVault.shared.forceServe()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Global Appearance
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func seasonAppearance() {

        // ── Navigation Bar ───────────────────
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = SaffronPalette.crust
        navAppearance.titleTextAttributes = [
            .foregroundColor: SaffronPalette.flour,
            .font: TypographyRecipe.cardLabel()
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: SaffronPalette.flour,
            .font: TypographyRecipe.chefTitle()
        ]
        navAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = SaffronPalette.honeyComb

        // ── Tab Bar ──────────────────────────
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = SaffronPalette.crust

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: SaffronPalette.ashDust,
            .font: TypographyRecipe.sprinkleTag()
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: SaffronPalette.honeyComb,
            .font: TypographyRecipe.sprinkleTag()
        ]

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = normalAttrs
        itemAppearance.normal.iconColor = SaffronPalette.ashDust
        itemAppearance.selected.titleTextAttributes = selectedAttrs
        itemAppearance.selected.iconColor = SaffronPalette.honeyComb

        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }

        // ── Table View ───────────────────────
        UITableView.appearance().backgroundColor = SaffronPalette.crust
        UITableView.appearance().separatorColor = SaffronPalette.crumbLine

        // ── Collection View ──────────────────
        UICollectionView.appearance().backgroundColor = SaffronPalette.crust

        // ── Text Field ───────────────────────
        UITextField.appearance().tintColor = SaffronPalette.honeyComb
        UITextField.appearance().keyboardAppearance = .dark

        // ── Switch ───────────────────────────
        UISwitch.appearance().onTintColor = SaffronPalette.honeyComb

        // ── Scroll Indicators ────────────────
        UIScrollView.appearance().indicatorStyle = .white

        // ── Alert Controller tint ────────────
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
            .tintColor = SaffronPalette.honeyComb

        // ── Status Bar ───────────────────────
        // Forced dark in Info.plist: UIUserInterfaceStyle = Dark
    }
}
