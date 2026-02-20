import Foundation

// MARK: - Category Resolver
// Resolves kindId/axisId to display info (name, icon) for both built-in and custom categories

enum CategoryResolver {

    // MARK: - Reminder Kind

    struct ReminderKindInfo {
        let id: String
        let name: String
        let icon: String
    }

    static func reminderKindInfo(kindId: String, customKinds: [CustomReminderKind]) -> ReminderKindInfo {
        if let builtIn = CareReminderKind(rawValue: kindId) {
            return ReminderKindInfo(id: builtIn.rawValue, name: builtIn.displayName, icon: builtIn.icon)
        }
        if let custom = customKinds.first(where: { $0.kindId == kindId }) {
            return ReminderKindInfo(id: custom.kindId, name: custom.name, icon: custom.icon)
        }
        return ReminderKindInfo(id: kindId, name: "Unknown", icon: "star.fill")
    }

    static func allReminderKinds(customKinds: [CustomReminderKind]) -> [ReminderKindInfo] {
        let builtIn = CareReminderKind.allCases.map {
            ReminderKindInfo(id: $0.rawValue, name: $0.displayName, icon: $0.icon)
        }
        let custom = customKinds.map {
            ReminderKindInfo(id: $0.kindId, name: $0.name, icon: $0.icon)
        }
        return builtIn + custom
    }

    // MARK: - Wellness Axis

    struct AxisInfo: Identifiable {
        let id: String
        let name: String
        let icon: String
        let levelHints: [String]
        var rawValue: String { id }
    }

    static func axisInfo(axisId: String, customAxes: [CustomWellnessAxis]) -> AxisInfo? {
        if let builtIn = WellnessAxis(rawValue: axisId) {
            return AxisInfo(
                id: builtIn.rawValue,
                name: builtIn.displayName,
                icon: builtIn.icon,
                levelHints: builtIn.levelHints
            )
        }
        if let custom = customAxes.first(where: { $0.rawValue == axisId }) {
            return AxisInfo(
                id: custom.rawValue,
                name: custom.name,
                icon: custom.icon,
                levelHints: ["Very low", "Low", "Moderate", "Good", "Excellent"]
            )
        }
        return nil
    }

    static func allAxes(settings: SanctuarySettings) -> [AxisInfo] {
        var result: [AxisInfo] = []
        for raw in settings.enabledAxes {
            if let builtIn = WellnessAxis(rawValue: raw) {
                result.append(AxisInfo(
                    id: builtIn.rawValue,
                    name: builtIn.displayName,
                    icon: builtIn.icon,
                    levelHints: builtIn.levelHints
                ))
            } else if let custom = settings.customWellnessAxes.first(where: { $0.rawValue == raw }) {
                result.append(AxisInfo(
                    id: custom.rawValue,
                    name: custom.name,
                    icon: custom.icon,
                    levelHints: ["Very low", "Low", "Moderate", "Good", "Excellent"]
                ))
            }
        }
        return result
    }
}
