import Foundation
import Combine

// MARK: - PulseViewModel
// Drives the main dashboard: today's scales, 7-day trends,
// recent episodes summary, insights, and gamification status

final class PulseViewModel: ObservableObject {

    // MARK: - Published State

    /// Current companion
    @Published var activeCompanion: CompanionProfile? = nil
    @Published var allCompanions: [CompanionProfile] = []

    /// Today's wellness log
    @Published var todayLog: DailyWellnessLog? = nil
    @Published var todayDateKey: String = Date().wellnessDateKey

    /// 7-day trend data per axis (keyed by axis id)
    @Published var trendSnapshots: [String: [TrendPoint]] = [:]

    /// Recent episodes summary (kind -> count)
    @Published var episodeTally: [SymptomKind: Int] = [:]
    @Published var recentEpisodeCount: Int = 0

    /// Insight cards
    @Published var activeInsights: [ObservationInsight] = []

    /// Gamification
    @Published var vitality: VitalityProgress = VitalityProgress()
    @Published var newBadgeEarned: GuardianBadge? = nil

    /// UI state
    @Published var isEmptyState: Bool = true
    @Published var toastText: String? = nil

    // MARK: - Enabled axes from settings (built-in + custom)
    var enabledAxisInfos: [CategoryResolver.AxisInfo] {
        CategoryResolver.allAxes(settings: GroveStorage.shared.settings)
    }

    // MARK: - Init

    init() {
        refresh()
    }

    // MARK: - Refresh All Data

    func refresh() {
        let storage = GroveStorage.shared

        // Companions
        allCompanions = storage.companions
        if let focused = activeCompanion,
           allCompanions.contains(where: { $0.id == focused.id }) {
            // keep current
        } else {
            activeCompanion = allCompanions.first
        }

        // Vitality
        vitality = storage.progress

        guard let companion = activeCompanion else {
            clearDashboard()
            return
        }

        // Today's log
        todayDateKey = Date().wellnessDateKey
        todayLog = storage.wellnessLog(for: companion.id, dateKey: todayDateKey)

        // Trends (7 days)
        computeTrends(for: companion.id)

        // Episode tally
        computeEpisodeTally(for: companion.id)

        // Insights
        computeInsights(for: companion.id)

        // Empty state
        isEmptyState = todayLog == nil && trendSnapshots.values.allSatisfy { $0.isEmpty }
    }

    // MARK: - Switch Companion

    func selectCompanion(_ companion: CompanionProfile) {
        activeCompanion = companion
        refresh()
    }

    // MARK: - Quick Scale Tap

    func tapScale(axisId: String, value: Int, axisName: String) {
        guard let companion = activeCompanion else { return }

        var log = todayLog ?? DailyWellnessLog(
            companionId: companion.id,
            date: todayDateKey
        )

        let previousBadges = Set(GroveStorage.shared.progress.unlockedBadges)

        log.setScale(axisId: axisId, value: value)
        log.loggedAt = Date()
        GroveStorage.shared.saveWellnessLog(log)
        todayLog = log

        // Check for new badge
        let currentBadges = Set(GroveStorage.shared.progress.unlockedBadges)
        if let newBadge = currentBadges.subtracting(previousBadges).first,
           let badge = GuardianBadge(rawValue: newBadge) {
            newBadgeEarned = badge
        }

        refresh()
        showToast("\(axisName) set to \(value)")
    }

    // MARK: - Reset Scale

    func resetScale(axisId: String, axisName: String) {
        guard var log = todayLog else { return }
        log.scales.removeValue(forKey: axisId)
        log.loggedAt = Date()
        GroveStorage.shared.saveWellnessLog(log)
        todayLog = log
        refresh()
        showToast("\(axisName) cleared")
    }

    // MARK: - Dismiss Insight

    func dismissInsight(_ insight: ObservationInsight) {
        activeInsights.removeAll { $0.id == insight.id }
    }

    // MARK: - Acknowledge Badge

    func acknowledgeBadge() {
        newBadgeEarned = nil
    }

    // MARK: - Trend Computation

    private func computeTrends(for companionId: UUID) {
        let logs = GroveStorage.shared.logsForCompanion(companionId, lastDays: 7)
        var snapshots: [String: [TrendPoint]] = [:]

        for axis in enabledAxisInfos {
            var points: [TrendPoint] = []
            for log in logs {
                if let val = log.scaleValue(forAxisId: axis.id) {
                    points.append(TrendPoint(dateKey: log.date, value: val))
                }
            }
            snapshots[axis.id] = points
        }

        trendSnapshots = snapshots
    }

    // MARK: - Episode Tally

    private func computeEpisodeTally(for companionId: UUID) {
        let recent = GroveStorage.shared.episodesForCompanion(companionId, lastDays: 7)
        var tally: [SymptomKind: Int] = [:]

        for episode in recent {
            tally[episode.kind, default: 0] += episode.occurrenceCount
        }

        episodeTally = tally
        recentEpisodeCount = recent.count
    }

    // MARK: - Insight Engine

    private func computeInsights(for companionId: UUID) {
        guard GroveStorage.shared.settings.insightsEnabled else {
            activeInsights = []
            return
        }

        var insights: [ObservationInsight] = []
        let logs = GroveStorage.shared.logsForCompanion(companionId, lastDays: 7)

        // Check for consecutive low values per axis
        for axis in enabledAxisInfos {
            let values = logs.compactMap { $0.scaleValue(forAxisId: axis.id) }
            let recentLow = values.suffix(3).filter { $0 <= 2 }
            if recentLow.count >= 2 {
                insights.append(ObservationInsight(
                    id: "low_\(axis.id)",
                    icon: axis.icon,
                    message: "\(axis.name) has been low for \(recentLow.count) recent days",
                    kind: .attention
                ))
            }
        }

        // Check for frequent episodes
        let episodes = GroveStorage.shared.episodesForCompanion(companionId, lastDays: 7)
        let grouped = Dictionary(grouping: episodes, by: { $0.kind })
        for (kind, group) in grouped where group.count >= 3 {
            insights.append(ObservationInsight(
                id: "freq_\(kind.rawValue)",
                icon: kind.icon,
                message: "\(kind.displayName) noted \(group.count) times this week",
                kind: .attention
            ))
        }

        // Positive: improving trend
        for axis in enabledAxisInfos {
            let values = logs.compactMap { $0.scaleValue(forAxisId: axis.id) }
            if values.count >= 4 {
                let firstHalf = values.prefix(values.count / 2)
                let secondHalf = values.suffix(values.count / 2)
                let avgFirst = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
                let avgSecond = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
                if avgSecond - avgFirst >= 1.0 {
                    insights.append(ObservationInsight(
                        id: "improve_\(axis.id)",
                        icon: "arrow.up.heart.fill",
                        message: "\(axis.name) is trending upward",
                        kind: .positive
                    ))
                }
            }
        }

        // Streak encouragement
        if vitality.currentStreak >= 3 {
            insights.append(ObservationInsight(
                id: "streak_\(vitality.currentStreak)",
                icon: "flame.fill",
                message: "\(vitality.currentStreak)-day streak! Keep observing.",
                kind: .positive
            ))
        }

        activeInsights = Array(insights.prefix(4))
    }

    // MARK: - Helpers

    private func clearDashboard() {
        todayLog = nil
        trendSnapshots = [:]
        episodeTally = [:]
        recentEpisodeCount = 0
        activeInsights = []
        isEmptyState = true
    }

    private func showToast(_ text: String) {
        toastText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.toastText == text {
                self?.toastText = nil
            }
        }
    }
}

// MARK: - Supporting Types

struct TrendPoint: Identifiable, Equatable {
    let id = UUID()
    let dateKey: String
    let value: Int
}

struct ObservationInsight: Identifiable, Equatable {
    let id: String
    let icon: String
    let message: String
    let kind: InsightTone

    enum InsightTone: Equatable {
        case positive
        case attention
        case neutral
    }
}
