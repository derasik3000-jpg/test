

import UIKit

// MARK: - 🎨 Saffron Palette (core colours)

/// Central colour registry inspired by RAL references in the spec.
/// Dark-mode first; gold & white act as accent tones.
enum SaffronPalette {

    // ── Backgrounds ──────────────────────────

    /// Deep charcoal base – main app background.
    /// Near-black with a warm undertone.
    static let crust     = UIColor(hex: 0x111111)

    /// Slightly lifted surface – cards, sheets.
    static let brioche   = UIColor(hex: 0x1C1C1E)

    /// Elevated container – modals, popovers.
    static let meringue  = UIColor(hex: 0x2C2C2E)

    // ── Brand Accent (gold) ──────────────────

    /// RAL 1036-inspired pearl gold.
    static let honeyComb      = UIColor(hex: 0xC5A253)

    /// Lighter gold for highlights / glow.
    static let butterGlaze    = UIColor(hex: 0xDDC27A)

    /// Muted gold for secondary chips / tags.
    static let caramelWhisper = UIColor(hex: 0x8C7438)

    // ── Text ─────────────────────────────────

    /// Primary white text on dark surfaces.
    static let flour          = UIColor.white

    /// Secondary text – lower emphasis.
    static let steamGrey      = UIColor(hex: 0xAEAEB2)

    /// Tertiary / placeholder.
    static let ashDust        = UIColor(hex: 0x636366)

    // ── Semantic ─────────────────────────────

    /// Positive / success.
    static let mintGarnish    = UIColor(hex: 0x30D158)

    /// Warning / attention.
    static let pepperFlake    = UIColor(hex: 0xFF9F0A)

    /// Error / destructive.
    static let tomatoPaste    = UIColor(hex: 0xFF453A)

    /// Locked-slot tint.
    static let frozenBerry    = UIColor(hex: 0x5E5CE6)

    // ── Buttons ──────────────────────────────

    /// Primary CTA – gold background.
    static let primaryCTA         = honeyComb
    static let primaryCTAText     = UIColor(hex: 0x111111)

    /// Secondary CTA – outline / ghost.
    static let secondaryCTABorder = steamGrey
    static let secondaryCTAText   = flour

    // ── Dividers / Separators ────────────────

    static let crumbLine = UIColor(hex: 0x38383A)
}

// MARK: - 🔤 Typographic Recipes

/// Font presets matching the design spec (SF Pro via system fonts).
enum TypographyRecipe {

    // ── Display ──────────────────────────────

    static func grandBanquet() -> UIFont {
        .systemFont(ofSize: 34, weight: .bold)
    }

    static func chefTitle() -> UIFont {
        .systemFont(ofSize: 28, weight: .bold)
    }

    // ── Headings ─────────────────────────────

    static func sectionRoast() -> UIFont {
        .systemFont(ofSize: 22, weight: .semibold)
    }

    static func cardLabel() -> UIFont {
        .systemFont(ofSize: 17, weight: .semibold)
    }

    // ── Body ─────────────────────────────────

    static func servingBody() -> UIFont {
        .systemFont(ofSize: 17, weight: .regular)
    }

    static func sideNote() -> UIFont {
        .systemFont(ofSize: 15, weight: .regular)
    }

    // ── Captions / Chips ─────────────────────

    static func croutonCaption() -> UIFont {
        .systemFont(ofSize: 13, weight: .medium)
    }

    static func sprinkleTag() -> UIFont {
        .systemFont(ofSize: 12, weight: .semibold)
    }

    // ── Buttons ──────────────────────────────

    static func primaryButton() -> UIFont {
        .systemFont(ofSize: 17, weight: .bold)
    }

    static func secondaryButton() -> UIFont {
        .systemFont(ofSize: 15, weight: .semibold)
    }

    // ── Numbers / Stats ──────────────────────

    static func ovenDigit() -> UIFont {
        .monospacedDigitSystemFont(ofSize: 48, weight: .heavy)
    }

    static func counterChip() -> UIFont {
        .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
    }
}

// MARK: - 📐 Kitchen Spacing

/// Consistent spacing tokens used across layouts.
enum KitchenSpacing {
    static let crumb:    CGFloat = 4
    static let garnish:  CGFloat = 8
    static let napkin:   CGFloat = 12
    static let plate:    CGFloat = 16
    static let tray:     CGFloat = 20
    static let platter:  CGFloat = 24
    static let banquet:  CGFloat = 32
    static let feast:    CGFloat = 48
}

// MARK: - 🌑 Shadow Seasoning

/// Shadow presets for elevation levels.
enum ShadowSeasoning {

    struct Flavor {
        let color: CGColor
        let opacity: Float
        let offset: CGSize
        let radius: CGFloat
    }

    /// Subtle card shadow.
    static let softGlow = Flavor(
        color: SaffronPalette.honeyComb.cgColor,
        opacity: 0.12,
        offset: CGSize(width: 0, height: 2),
        radius: 8
    )

    /// Medium elevation.
    static let warmToast = Flavor(
        color: UIColor.black.cgColor,
        opacity: 0.35,
        offset: CGSize(width: 0, height: 4),
        radius: 12
    )

    /// Deep modal shadow.
    static let deepFry = Flavor(
        color: UIColor.black.cgColor,
        opacity: 0.55,
        offset: CGSize(width: 0, height: 8),
        radius: 24
    )
}

// MARK: - 📏 Corner Rounding

enum PlatingCorner {
    static let crouton:  CGFloat = 6
    static let biscuit:  CGFloat = 10
    static let muffin:   CGFloat = 14
    static let bundt:    CGFloat = 20
    static let soufflé:  CGFloat = 28
}

// MARK: - 🛠 Reusable UI Builders

extension SaffronPalette {

    // ── Primary Button ───────────────────────

    /// Returns a gold-filled, dark-text CTA button.
    static func brewPrimaryButton(titled label: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(label, for: .normal)
        btn.titleLabel?.font = TypographyRecipe.primaryButton()
        btn.setTitleColor(primaryCTAText, for: .normal)
        btn.backgroundColor = primaryCTA
        btn.layer.cornerRadius = PlatingCorner.muffin
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return btn
    }

    // ── Secondary (Outline) Button ───────────

    static func brewSecondaryButton(titled label: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(label, for: .normal)
        btn.titleLabel?.font = TypographyRecipe.secondaryButton()
        btn.setTitleColor(secondaryCTAText, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = PlatingCorner.muffin
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = secondaryCTABorder.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return btn
    }

    // ── Tag / Chip View ──────────────────────

    static func brewTagChip(text: String, filled: Bool = false) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = PlatingCorner.crouton
        container.backgroundColor = filled ? caramelWhisper.withAlphaComponent(0.3) : .clear
        container.layer.borderWidth = filled ? 0 : 1
        container.layer.borderColor = caramelWhisper.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = text
        lbl.font = TypographyRecipe.sprinkleTag()
        lbl.textColor = filled ? butterGlaze : steamGrey
        lbl.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.crumb),
            lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.crumb),
            lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.garnish),
            lbl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.garnish),
        ])
        return container
    }

    // ── Styled Text Field ────────────────────

    static func brewTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.font = TypographyRecipe.servingBody()
        tf.textColor = flour
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: ashDust]
        )
        tf.backgroundColor = meringue
        tf.layer.cornerRadius = PlatingCorner.biscuit
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.rightViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        tf.keyboardAppearance = .dark
        tf.tintColor = honeyComb
        return tf
    }

    // ── Separator Line ───────────────────────

    static func brewSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = crumbLine
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }
}

// MARK: - 🎯 UIView Shadow Extension

extension UIView {

    func applySeasoning(_ flavor: ShadowSeasoning.Flavor) {
        layer.shadowColor   = flavor.color
        layer.shadowOpacity = flavor.opacity
        layer.shadowOffset  = flavor.offset
        layer.shadowRadius  = flavor.radius
        layer.masksToBounds = false
    }
}

// MARK: - 🎨 UIColor Hex Helper

extension UIColor {

    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8)  & 0xFF) / 255.0
        let b = CGFloat( hex        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - 🏷 Meal-Type Emoji Mapping (gamification visual)

enum MealBadgeIcon: Int, CaseIterable {
    case breakfast = 0
    case lunch     = 1
    case dinner    = 2
    case snack     = 3

    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch:     return "☀️"
        case .dinner:    return "🌙"
        case .snack:     return "⭐️"
        }
    }

    var displayTitle: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        case .snack:     return "Snack"
        }
    }

    var sfSymbol: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch:     return "sun.max.fill"
        case .dinner:    return "moon.stars.fill"
        case .snack:     return "sparkles"
        }
    }

    var tintColor: UIColor {
        switch self {
        case .breakfast: return UIColor(hex: 0xFFD60A)
        case .lunch:     return UIColor(hex: 0xFF9F0A)
        case .dinner:    return UIColor(hex: 0xBF5AF2)
        case .snack:     return UIColor(hex: 0x64D2FF)
        }
    }
}

// MARK: - 🏅 Gamification Badge Helpers

/// Achievement-style visual tokens used across the app.
enum KitchenBadge {

    struct Trophy {
        let icon: String   // SF Symbol name
        let title: String
        let tint: UIColor
    }

    static let fullPantry = Trophy(
        icon: "checkmark.seal.fill",
        title: "Full Pantry",
        tint: SaffronPalette.mintGarnish
    )

    static let weekChef = Trophy(
        icon: "flame.fill",
        title: "Week Chef",
        tint: SaffronPalette.pepperFlake
    )

    static let smartShopper = Trophy(
        icon: "cart.fill",
        title: "Smart Shopper",
        tint: SaffronPalette.honeyComb
    )

    static let varietyMaster = Trophy(
        icon: "star.circle.fill",
        title: "Variety Master",
        tint: SaffronPalette.frozenBerry
    )
}

// MARK: - ✨ Animation Presets

enum PlatingAnimation {

    /// Standard spring for card inserts.
    static let cardSpring: (TimeInterval, CGFloat, CGFloat) = (0.55, 0.72, 0.4)

    /// Quick fade for secondary elements.
    static let gentleFade: TimeInterval = 0.25

    /// Bounce for CTA attention.
    static let buttonPop: TimeInterval = 0.35

    static func performCardSpring(_ animations: @escaping () -> Void,
                                  completion: ((Bool) -> Void)? = nil) {
        let (duration, damping, velocity) = cardSpring
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.curveEaseInOut],
            animations: animations,
            completion: completion
        )
    }

    static func performGentleFade(_ animations: @escaping () -> Void,
                                  completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: gentleFade,
            delay: 0,
            options: [.curveEaseInOut],
            animations: animations,
            completion: completion
        )
    }
}
