import SwiftUI

// MARK: - AuraPalette
// Black & Gold health-themed color tokens
// Every name reflects the spirit of wellness and vitality

enum AuraPalette {

    // MARK: - Backgrounds (Deep & Grounding)

    /// Main app background — deep obsidian black
    static let restingNight = Color(red: 0.07, green: 0.07, blue: 0.09)

    /// Card / surface background — slightly lighter charcoal
    static let healingCharcoal = Color(red: 0.12, green: 0.12, blue: 0.14)

    /// Elevated surface (sheets, modals) — warm dark grey
    static let shelterSmoke = Color(red: 0.17, green: 0.17, blue: 0.19)

    // MARK: - Accents (Energy & Warmth)

    /// Primary gold accent — vitality, achievement, warmth
    static let lifeGold = Color(red: 1.0, green: 0.78, blue: 0.20)

    /// Secondary gold — softer, for backgrounds behind gold text
    static let amberPulse = Color(red: 0.85, green: 0.65, blue: 0.12)

    /// Dimmed gold — for inactive/disabled gold elements
    static let fadedElixir = Color(red: 0.55, green: 0.45, blue: 0.15)

    // MARK: - Text (Clarity & Trust)

    /// Primary text — pure white for readability on dark
    static let boneWhite = Color.white

    /// Secondary text — soft grey for descriptions
    static let mistBreath = Color(red: 0.65, green: 0.65, blue: 0.68)

    /// Tertiary text — very subtle grey for timestamps
    static let whisperAsh = Color(red: 0.42, green: 0.42, blue: 0.45)

    // MARK: - Semantic (Signals without Alarm)

    /// Positive / good observation
    static let sproutGreen = Color(red: 0.30, green: 0.78, blue: 0.45)

    /// Neutral / mid observation
    static let calmSky = Color(red: 0.40, green: 0.65, blue: 0.88)

    /// Attention needed — warm amber (not alarming red)
    static let emberWarn = Color(red: 0.92, green: 0.45, blue: 0.25)

    // MARK: - Gamification

    /// XP bar fill color
    static let experienceGlow = Color(red: 1.0, green: 0.82, blue: 0.30)

    /// Streak flame color
    static let streakFlame = Color(red: 1.0, green: 0.55, blue: 0.15)

    /// Badge shimmer
    static let trophyShine = Color(red: 1.0, green: 0.88, blue: 0.45)

    /// Level-up burst
    static let ascensionBurst = Color(red: 0.95, green: 0.75, blue: 0.10)

    // MARK: - Gradients

    static let nightfallGradient = LinearGradient(
        colors: [restingNight, healingCharcoal],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldAuraGradient = LinearGradient(
        colors: [lifeGold, amberPulse],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGlowGradient = LinearGradient(
        colors: [healingCharcoal, shelterSmoke.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Opacity Helpers

    static let glassOverlay = Color.white.opacity(0.05)
    static let goldMist = lifeGold.opacity(0.12)
    static let shadowVeil = Color.black.opacity(0.4)
}

// MARK: - AuraFont
// Consistent typography tokens

enum AuraFont {

    static func heroTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    static func sectionHeadline() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }

    static func cardTitle() -> Font {
        .system(size: 16, weight: .semibold, design: .rounded)
    }

    static func bodyPulse() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    static func captionWhisper() -> Font {
        .system(size: 12, weight: .medium, design: .default)
    }

    static func badgeStamp() -> Font {
        .system(size: 10, weight: .bold, design: .rounded)
    }

    static func xpCounter() -> Font {
        .system(size: 14, weight: .heavy, design: .monospaced)
    }

    static func streakDigit() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }

    static func scaleValue() -> Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }
}
