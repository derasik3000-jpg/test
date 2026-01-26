import Foundation

public struct PreferenceSnapshot {
    public var onboardingShown: Bool
    public var notificationsAllowedCached: Bool
    public var historyRetentionDays: Int
    
    public init(
        onboardingShown: Bool = false,
        notificationsAllowedCached: Bool = false,
        historyRetentionDays: Int = 365
    ) {
        self.onboardingShown = onboardingShown
        self.notificationsAllowedCached = notificationsAllowedCached
        self.historyRetentionDays = historyRetentionDays
    }
}

