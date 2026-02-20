import Foundation
import Combine

// MARK: - SanctumViewModel
// Drives the Sanctum tab: user avatar, lifetime stats,
// badge showcase, companion list, share, settings

final class SanctumViewModel: ObservableObject {

    // MARK: - Published State

    /// User avatar emoji
    @Published var userAvatar: String = "😊"

    /// Vitality progress
    @Published var vitality: VitalityProgress = VitalityProgress()

    /// All badges with unlock status
    @Published var badgeStates: [BadgeDisplayState] = []

    /// Companions list
    @Published var companions: [CompanionProfile] = []

    /// Lifetime stats
    @Published var lifetimeStats: LifetimeSnapshot = LifetimeSnapshot()

    /// Settings
    @Published var enabledAxes: Set<String> = []
    @Published var insightsEnabled: Bool = true
    @Published var defaultRangeDays: Int = 7
    @Published var customWellnessAxes: [CustomWellnessAxis] = []
    @Published var customReminderKinds: [CustomReminderKind] = []

    /// UI
    @Published var toastText: String? = nil
    @Published var showPurgeConfirmation: Bool = false
    @Published var showDeleteCompanionConfirmation: Bool = false
    @Published var companionToDelete: CompanionProfile? = nil
    @Published var showUndoCompanionToast: Bool = false

    // MARK: - Init

    init() {
        refresh()
    }

    // MARK: - Refresh

    func refresh() {
        let storage = GroveStorage.shared

        userAvatar = storage.settings.userAvatarEmoji
        vitality = storage.progress
        companions = storage.companions

        // Badge states
        badgeStates = GuardianBadge.allCases.map { badge in
            BadgeDisplayState(
                badge: badge,
                isUnlocked: storage.progress.unlockedBadges.contains(badge.rawValue)
            )
        }

        // Settings
        enabledAxes = Set(storage.settings.enabledAxes)
        insightsEnabled = storage.settings.insightsEnabled
        defaultRangeDays = storage.settings.defaultRangeDays
        customWellnessAxes = storage.settings.customWellnessAxes
        customReminderKinds = storage.settings.customReminderKinds

        // Compute lifetime stats
        computeLifetimeStats()
    }

    // MARK: - User Avatar

    func selectAvatar(_ emoji: String) {
        userAvatar = emoji
        var settings = GroveStorage.shared.settings
        settings.userAvatarEmoji = emoji
        GroveStorage.shared.saveSettings(settings)
        showToast("Avatar updated")
    }

    // MARK: - Axes Toggle

    func toggleAxis(_ axis: WellnessAxis) {
        let key = axis.rawValue
        if enabledAxes.contains(key) {
            // Don't allow disabling all
            guard enabledAxes.count > 1 else {
                showToast("Keep at least one scale active")
                return
            }
            enabledAxes.remove(key)
        } else {
            enabledAxes.insert(key)
        }
        saveSettings()
    }

    func isAxisEnabled(_ axis: WellnessAxis) -> Bool {
        enabledAxes.contains(axis.rawValue)
    }

    func isAxisEnabled(_ axisId: String) -> Bool {
        enabledAxes.contains(axisId)
    }

    func toggleAxis(_ axisId: String) {
        if enabledAxes.contains(axisId) {
            guard enabledAxes.count > 1 else {
                showToast("Keep at least one scale active")
                return
            }
            enabledAxes.remove(axisId)
        } else {
            enabledAxes.insert(axisId)
        }
        saveSettings()
    }

    // MARK: - Custom Wellness Axes

    func addCustomWellnessAxis(name: String, icon: String) {
        let id = UUID().uuidString
        let axis = CustomWellnessAxis(id: id, name: name, icon: icon)
        var settings = GroveStorage.shared.settings
        settings.customWellnessAxes.append(axis)
        settings.enabledAxes.append(axis.rawValue)
        GroveStorage.shared.saveSettings(settings)
        refresh()
        showToast("Scale added")
    }

    func removeCustomWellnessAxis(_ axis: CustomWellnessAxis) {
        guard enabledAxes.count > 1 else {
            showToast("Keep at least one scale active")
            return
        }
        var settings = GroveStorage.shared.settings
        settings.customWellnessAxes.removeAll { $0.id == axis.id }
        settings.enabledAxes.removeAll { $0 == axis.rawValue }
        GroveStorage.shared.saveSettings(settings)
        refresh()
        showToast("Scale removed")
    }

    // MARK: - Custom Reminder Kinds

    func addCustomReminderKind(name: String, icon: String) {
        let id = UUID().uuidString
        let kind = CustomReminderKind(id: id, name: name, icon: icon)
        var settings = GroveStorage.shared.settings
        settings.customReminderKinds.append(kind)
        GroveStorage.shared.saveSettings(settings)
        refresh()
        showToast("Category added")
    }

    func removeCustomReminderKind(_ kind: CustomReminderKind) {
        var settings = GroveStorage.shared.settings
        settings.customReminderKinds.removeAll { $0.id == kind.id }
        GroveStorage.shared.saveSettings(settings)
        refresh()
        showToast("Category removed")
    }

    // MARK: - Insights Toggle

    func toggleInsights() {
        insightsEnabled.toggle()
        saveSettings()
    }

    // MARK: - Default Range

    func setDefaultRange(_ days: Int) {
        defaultRangeDays = days
        saveSettings()
    }

    // MARK: - Companion Management

    private var pendingUndoCompanion: CompanionProfile?
    private var pendingUndoLogs: [DailyWellnessLog] = []
    private var pendingUndoEpisodes: [SymptomEpisode] = []

    func requestDeleteCompanion(_ companion: CompanionProfile) {
        companionToDelete = companion
        showDeleteCompanionConfirmation = true
    }

    func confirmDeleteCompanion() {
        guard let companion = companionToDelete else { return }

        // Store for undo
        pendingUndoCompanion = companion
        pendingUndoLogs = GroveStorage.shared.wellnessLogs.filter { $0.companionId == companion.id }
        pendingUndoEpisodes = GroveStorage.shared.episodes.filter { $0.companionId == companion.id }

        GroveStorage.shared.removeCompanion(id: companion.id)
        companionToDelete = nil
        showDeleteCompanionConfirmation = false
        refresh()
        toastText = "\(companion.name) removed"
        showUndoCompanionToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, self.showUndoCompanionToast else { return }
            self.pendingUndoCompanion = nil
            self.pendingUndoLogs = []
            self.pendingUndoEpisodes = []
            self.showUndoCompanionToast = false
            self.toastText = nil
        }
    }

    func cancelDeleteCompanion() {
        companionToDelete = nil
        showDeleteCompanionConfirmation = false
    }

    func undoCompanionDelete() {
        guard let companion = pendingUndoCompanion else { return }
        GroveStorage.shared.saveCompanion(companion)
        for log in pendingUndoLogs {
            GroveStorage.shared.saveWellnessLog(log)
        }
        for episode in pendingUndoEpisodes {
            GroveStorage.shared.saveEpisode(episode)
        }
        pendingUndoCompanion = nil
        pendingUndoLogs = []
        pendingUndoEpisodes = []
        showUndoCompanionToast = false
        toastText = nil
        refresh()
        showToast("\(companion.name) restored")
    }

    // MARK: - Share Progress

    func buildShareText() -> String {
        let v = vitality
        var lines: [String] = []

        lines.append("🐾 Pet Log: True Feel Progress")
        lines.append("━━━━━━━━━━━━━━━")
        lines.append("⭐ Level \(v.currentLevel) — \(v.levelTitle)")
        lines.append("✨ \(v.totalXP) XP earned")
        lines.append("🔥 \(v.currentStreak)-day streak (best: \(v.longestStreak))")
        lines.append("📊 \(v.totalLogs) logs · \(v.totalEpisodes) episodes")
        lines.append("🏅 \(v.unlockedBadges.count)/\(GuardianBadge.allCases.count) badges")

        if !v.unlockedBadges.isEmpty {
            let badgeIcons = v.unlockedBadges.compactMap { raw in
                GuardianBadge(rawValue: raw)?.icon
            }.joined(separator: " ")
            lines.append("   \(badgeIcons)")
        }

        lines.append("")
        lines.append("Tracking \(companions.count) companion\(companions.count == 1 ? "" : "s")")

        return lines.joined(separator: "\n")
    }

    // MARK: - Purge

    func requestPurge() {
        showPurgeConfirmation = true
    }

    func confirmPurge() {
        GroveStorage.shared.purgeAllData()
        showPurgeConfirmation = false
        refresh()
        showToast("All data erased")
    }

    func cancelPurge() {
        showPurgeConfirmation = false
    }

    // MARK: - Lifetime Stats

    private func computeLifetimeStats() {
        let storage = GroveStorage.shared

        let allLogs = storage.wellnessLogs
        let allEpisodes = storage.episodes

        // Total days with at least one scale
        let loggedDays = Set(allLogs.filter { !$0.scales.isEmpty }.map(\.date))

        // Most common episode
        let episodeGroups = Dictionary(grouping: allEpisodes, by: { $0.kind })
        let topEpisode = episodeGroups.max(by: { $0.value.count < $1.value.count })

        // Average scales
        var axisAverages: [WellnessAxis: Double] = [:]
        for axis in WellnessAxis.allCases {
            let values = allLogs.compactMap { $0.scaleValue(for: axis) }
            if !values.isEmpty {
                axisAverages[axis] = Double(values.reduce(0, +)) / Double(values.count)
            }
        }

        // Most active companion
        let companionLogCounts = Dictionary(grouping: allLogs, by: { $0.companionId })
        let topCompanionId = companionLogCounts.max(by: { $0.value.count < $1.value.count })?.key
        let topCompanion = storage.companions.first(where: { $0.id == topCompanionId })

        lifetimeStats = LifetimeSnapshot(
            totalDaysLogged: loggedDays.count,
            totalEpisodes: allEpisodes.count,
            topEpisodeKind: topEpisode?.key,
            topEpisodeCount: topEpisode?.value.count ?? 0,
            axisAverages: axisAverages,
            mostActiveCompanion: topCompanion?.name,
            joinedDaysAgo: daysSinceFirstLog(allLogs)
        )
    }

    private func daysSinceFirstLog(_ logs: [DailyWellnessLog]) -> Int {
        guard let earliest = logs.map(\.date).sorted().first,
              let date = earliest.dateFromWellnessKey else { return 0 }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }

    // MARK: - Save Settings

    private func saveSettings() {
        var settings = GroveStorage.shared.settings
        settings.enabledAxes = Array(enabledAxes)
        settings.insightsEnabled = insightsEnabled
        settings.defaultRangeDays = defaultRangeDays
        settings.customWellnessAxes = customWellnessAxes
        settings.customReminderKinds = customReminderKinds
        GroveStorage.shared.saveSettings(settings)
    }

    // MARK: - Toast

    private func showToast(_ text: String) {
        toastText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.toastText == text {
                self?.toastText = nil
            }
        }
    }
}

// MARK: - Badge Display State

struct BadgeDisplayState: Identifiable, Equatable {
    let badge: GuardianBadge
    let isUnlocked: Bool

    var id: String { badge.id }
}

// MARK: - Lifetime Snapshot

struct LifetimeSnapshot: Equatable {
    var totalDaysLogged: Int = 0
    var totalEpisodes: Int = 0
    var topEpisodeKind: SymptomKind? = nil
    var topEpisodeCount: Int = 0
    var axisAverages: [WellnessAxis: Double] = [:]
    var mostActiveCompanion: String? = nil
    var joinedDaysAgo: Int = 0
}

// MARK: - Avatar Options

enum SpiritAvatarSet {
    static let collection: [[String]] = [
        // Faces
        ["😊", "😎", "🤓", "🥳", "😇", "🧐", "🤠", "🥰"],
        // Animals
        ["🐶", "🐱", "🐰", "🐻", "🦊", "🐼", "🦁", "🐨"],
        // Nature
        ["🌟", "🔥", "💎", "🌈", "🍀", "🌸", "⚡", "❄️"],
        // Cosmic
        ["🌙", "☀️", "🪐", "✨", "🌊", "🎭", "🦋", "🕊️"]
    ]

    static let sectionNames = ["Faces", "Animals", "Nature", "Cosmic"]
}
