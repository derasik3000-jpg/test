// ──────────────────────────────────────────────
// BistroTabBarController.swift
// с8 – "Menu of 12 Dishes"
//
// Custom UITabBarController with gold accent
// indicator, shopping badge, haptic feedback,
// and subtle selection animations.
// ──────────────────────────────────────────────

import UIKit

final class BistroTabBarController: UITabBarController {

    // ── Gold underline indicator ─────────────

    private let flameStripe: UIView = {
        let v = UIView()
        v.backgroundColor = SaffronPalette.honeyComb
        v.layer.cornerRadius = 1.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var stripeLeading: NSLayoutConstraint?
    private var stripeWidth: NSLayoutConstraint?

    // ── Observer token ───────────────────────

    private var ledgerObserver: NSObjectProtocol?

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureBarSurface()
        installFlameStripe()
        listenForBadgeUpdates()
        refreshShoppingBadge()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        moveStripe(to: selectedIndex, animated: false)
    }

    deinit {
        if let tok = ledgerObserver {
            NotificationCenter.default.removeObserver(tok)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Tab Bar Surface
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func configureBarSurface() {
        // Thin gold separator line above tab bar
        let topLine = UIView()
        topLine.backgroundColor = SaffronPalette.honeyComb.withAlphaComponent(0.2)
        topLine.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(topLine)
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: tabBar.topAnchor),
            topLine.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Flame Stripe (selection indicator)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func installFlameStripe() {
        tabBar.addSubview(flameStripe)

        let leading = flameStripe.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor)
        let width = flameStripe.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            flameStripe.topAnchor.constraint(equalTo: tabBar.topAnchor),
            flameStripe.heightAnchor.constraint(equalToConstant: 3),
            leading,
            width,
        ])

        stripeLeading = leading
        stripeWidth = width
    }

    private func moveStripe(to index: Int, animated: Bool) {
        guard let items = tabBar.items, index < items.count else { return }

        let tabCount = CGFloat(items.count)
        let tabWidth = tabBar.bounds.width / tabCount
        let padding: CGFloat = tabWidth * 0.2
        let indicatorWidth = tabWidth - padding * 2
        let x = tabWidth * CGFloat(index) + padding

        stripeLeading?.constant = x
        stripeWidth?.constant = indicatorWidth

        if animated {
            PlatingAnimation.performCardSpring {
                self.tabBar.layoutIfNeeded()
            }
        } else {
            tabBar.layoutIfNeeded()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Shopping Badge
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func listenForBadgeUpdates() {
        ledgerObserver = NotificationCenter.default.addObserver(
            forName: CellarVault.ledgerDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshShoppingBadge()
        }
    }

    private func refreshShoppingBadge() {
        guard let items = tabBar.items, items.count >= 3 else { return }
        let shoppingTab = items[2] // Shopping is tab index 2

        let vault = CellarVault.shared
        guard let currentWeek = vault.currentFeastWeek(),
              let roll = vault.groceryRoll(forWeek: currentWeek.id) else {
            shoppingTab.badgeValue = nil
            return
        }

        let remaining = roll.items.filter { !$0.isChecked && !$0.isOwned }.count
        if remaining > 0 {
            shoppingTab.badgeValue = "\(remaining)"
            shoppingTab.badgeColor = SaffronPalette.honeyComb
        } else {
            shoppingTab.badgeValue = nil
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Tab Icon Bounce
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func bounceTabIcon(at index: Int) {
        guard !FrostBox.shouldReduceMotion else { return }

        // Find the tab bar button's image view
        let tabButtons = tabBar.subviews
            .filter { String(describing: type(of: $0)).contains("TabBarButton") }
            .sorted { $0.frame.origin.x < $1.frame.origin.x }

        guard index < tabButtons.count else { return }
        let button = tabButtons[index]

        // Find the image view inside
        guard let imageView = button.subviews.compactMap({ $0 as? UIImageView }).first
                ?? button.subviews.flatMap({ $0.subviews }).compactMap({ $0 as? UIImageView }).first
        else { return }

        let bounce = CAKeyframeAnimation(keyPath: "transform.scale")
        bounce.values = [1.0, 1.25, 0.95, 1.05, 1.0]
        bounce.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        bounce.duration = 0.35
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageView.layer.add(bounce, forKey: "tabBounce")
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Haptics
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func tickHaptic() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - UITabBarControllerDelegate
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension BistroTabBarController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        moveStripe(to: selectedIndex, animated: true)
        bounceTabIcon(at: selectedIndex)
        tickHaptic()
    }

    /// Optional: custom transition animation between tabs.
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard !FrostBox.shouldReduceMotion else { return nil }
        let fromIdx = tabBarController.viewControllers?.firstIndex(of: fromVC) ?? 0
        let toIdx = tabBarController.viewControllers?.firstIndex(of: toVC) ?? 0
        return BistroTabTransition(goingRight: toIdx > fromIdx)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🎞 Tab Transition Animator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Lightweight slide + fade transition between tabs.
private final class BistroTabTransition: NSObject, UIViewControllerAnimatedTransitioning {

    private let goingRight: Bool

    init(goingRight: Bool) {
        self.goingRight = goingRight
        super.init()
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.28
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let width = container.bounds.width
        let offset: CGFloat = width * 0.15
        let direction: CGFloat = goingRight ? 1 : -1

        toView.frame = container.bounds
        toView.alpha = 0
        toView.transform = CGAffineTransform(translationX: offset * direction, y: 0)
        container.addSubview(toView)

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            fromView.alpha = 0
            fromView.transform = CGAffineTransform(translationX: -offset * direction, y: 0)
            toView.alpha = 1
            toView.transform = .identity
        } completion: { finished in
            fromView.transform = .identity
            fromView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
