// ──────────────────────────────────────────────
// KitchenPortraitViewController.swift
// Culinary Routine Choose & Chill
//
// Wrapper for native SwiftUI content enforcing
// STRICT portrait-only orientation (never landscape).
// ──────────────────────────────────────────────

import SwiftUI
import UIKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍽 KitchenPortraitViewController
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class KitchenPortraitViewController: UIViewController {

    private let content: AnyView

    init<Content: View>(content: Content) {
        self.content = AnyView(content)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.clipsToBounds = true
        view.insetsLayoutMarginsFromSafeArea = false
        additionalSafeAreaInsets = .zero

        let hosting = UIHostingController(rootView: content)
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        hosting.view.isOpaque = false
        hosting.view.clipsToBounds = true
        hosting.view.insetsLayoutMarginsFromSafeArea = false
        hosting.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        forcePortraitOrientation()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var shouldAutorotate: Bool { false }

    private func forcePortraitOrientation() {
        if #available(iOS 16.0, *) {
            if let windowScene = view.window?.windowScene {
                let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                windowScene.requestGeometryUpdate(prefs) { _ in }
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - SwiftUI Wrapper
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct KitchenPortraitWrapper<Content: View>: UIViewControllerRepresentable {

    let content: Content

    func makeUIViewController(context: Context) -> KitchenPortraitViewController {
        KitchenPortraitViewController(content: content)
    }

    func updateUIViewController(_ uiViewController: KitchenPortraitViewController, context: Context) {}
}
