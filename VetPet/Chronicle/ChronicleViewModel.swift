import Foundation
import Combine

// MARK: - ChronicleViewModel
// Drives the Chronicle tab: calendar strip, daily scale editing,
// day notes, symptom episodes list with filters

final class ChronicleViewModel: ObservableObject {

    // MARK: - Mode Toggle

    enum LedgerMode: String, CaseIterable, Identifiable {
        case logs   = "logs"
        case events = "events"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .logs:   return "Daily Logs"
            case .events: return "Episodes"
            }
        }

        var icon: String {
            switch self {
            case .logs:   return "calendar"
            case .events: return "list.bullet.clipboard"
            }
        }
    }

    // MARK: - Published State

    @Published var activeMode: LedgerMode = .logs
    @Published var activeCompanion: CompanionProfile? = nil
    @Published var allCompanions: [CompanionProfile] = []

    // -- Logs mode --
    @Published var calendarDays: [CalendarDayCell] = []
    @Published var selectedDateKey: String = Date().wellnessDateKey
    @Published var selectedLog: DailyWellnessLog? = nil
    @Published var dayNoteText: String = ""
    @Published var hasUnsavedChanges: Bool = false

    // -- Events mode --
    @Published var filteredEpisodes: [SymptomEpisode] = []
    @Published var episodeFilter: SymptomKind? = nil
    @Published var rangeDays: Int = 7

    // -- UI --
    @Published var toastText: String? = nil
    @Published var showUndoEpisodeToast: Bool = false

    // MARK: - Settings

    var enabledAxisInfos: [CategoryResolver.AxisInfo] {
        CategoryResolver.allAxes(settings: GroveStorage.shared.settings)
    }

    // MARK: - Init

    init() {
        refresh()
    }

    // MARK: - Refresh

    func refresh() {
        let storage = GroveStorage.shared
        allCompanions = storage.companions

        if let current = activeCompanion,
           allCompanions.contains(where: { $0.id == current.id }) {
            // keep
        } else {
            activeCompanion = allCompanions.first
        }

        refreshCalendar()
        loadSelectedDay()
        refreshEpisodes()
    }

    // MARK: - Companion Switch

    func selectCompanion(_ companion: CompanionProfile) {
        activeCompanion = companion
        refresh()
    }

    // MARK: - Mode Switch

    func switchMode(_ mode: LedgerMode) {
        activeMode = mode
    }

    // MARK: - Calendar Strip (14 days)

    private func refreshCalendar() {
        guard let companion = activeCompanion else {
            calendarDays = []
            return
        }

        let calendar = Calendar.current
        let today = Date()
        var days: [CalendarDayCell] = []

        for offset in (-13...0).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let key = date.wellnessDateKey
            let log = GroveStorage.shared.wellnessLog(for: companion.id, dateKey: key)
            let hasLog = log != nil && !(log!.scales.isEmpty)
            let episodeCount = GroveStorage.shared.episodes
                .filter { $0.companionId == companion.id && $0.occurredAt.wellnessDateKey == key }
                .count

            let dayNum = calendar.component(.day, from: date)
            let weekday = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]

            days.append(CalendarDayCell(
                dateKey: key,
                dayNumber: dayNum,
                weekdayLabel: weekday.uppercased(),
                hasLog: hasLog,
                episodeCount: episodeCount,
                isToday: key == today.wellnessDateKey,
                isSelected: key == selectedDateKey
            ))
        }

        calendarDays = days
    }

    // MARK: - Day Selection

    func selectDay(_ dateKey: String) {
        selectedDateKey = dateKey
        refreshCalendar()
        loadSelectedDay()
    }

    private func loadSelectedDay() {
        guard let companion = activeCompanion else {
            selectedLog = nil
            dayNoteText = ""
            return
        }

        let log = GroveStorage.shared.wellnessLog(for: companion.id, dateKey: selectedDateKey)
        selectedLog = log
        dayNoteText = log?.dayNote ?? ""
        hasUnsavedChanges = false
    }

    // MARK: - Scale Tap (autopersist)

    func tapScale(axisId: String, value: Int) {
        guard let companion = activeCompanion else { return }

        var log = selectedLog ?? DailyWellnessLog(
            companionId: companion.id,
            date: selectedDateKey
        )

        log.setScale(axisId: axisId, value: value)
        log.loggedAt = Date()
        GroveStorage.shared.saveWellnessLog(log)
        selectedLog = log

        refreshCalendar()
        let axisName = CategoryResolver.axisInfo(axisId: axisId, customAxes: GroveStorage.shared.settings.customWellnessAxes)?.name ?? "Scale"
        showToast("\(axisName): \(value)")
    }

    // MARK: - Day Note

    func updateDayNote(_ text: String) {
        dayNoteText = text
        hasUnsavedChanges = true
    }

    func saveDayNote() {
        guard let companion = activeCompanion else { return }

        var log = selectedLog ?? DailyWellnessLog(
            companionId: companion.id,
            date: selectedDateKey
        )

        log.dayNote = dayNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        log.loggedAt = Date()
        GroveStorage.shared.saveWellnessLog(log)
        selectedLog = log
        hasUnsavedChanges = false
        showToast("Note saved")
    }

    // MARK: - Copy Yesterday

    func copyPreviousDay() {
        guard let companion = activeCompanion else { return }

        let calendar = Calendar.current
        guard let selectedDate = selectedDateKey.dateFromWellnessKey,
              let yesterday = calendar.date(byAdding: .day, value: -1, to: selectedDate) else { return }

        let yesterdayKey = yesterday.wellnessDateKey
        guard let yesterdayLog = GroveStorage.shared.wellnessLog(for: companion.id, dateKey: yesterdayKey) else {
            showToast("No data for previous day")
            return
        }

        var log = selectedLog ?? DailyWellnessLog(
            companionId: companion.id,
            date: selectedDateKey
        )

        log.scales = yesterdayLog.scales
        log.loggedAt = Date()
        GroveStorage.shared.saveWellnessLog(log)
        selectedLog = log

        refreshCalendar()
        showToast("Copied from previous day")
    }

    // MARK: - Clear Day

    func clearDay() {
        guard let companion = activeCompanion else { return }

        var log = selectedLog ?? DailyWellnessLog(
            companionId: companion.id,
            date: selectedDateKey
        )

        log.scales = [:]
        log.dayNote = ""
        log.loggedAt = Date()
        GroveStorage.shared.saveWellnessLog(log)
        selectedLog = log
        dayNoteText = ""
        hasUnsavedChanges = false

        refreshCalendar()
        showToast("Day cleared")
    }

    // MARK: - Episodes

    private func refreshEpisodes() {
        guard let companion = activeCompanion else {
            filteredEpisodes = []
            return
        }

        var all = GroveStorage.shared.episodesForCompanion(companion.id, lastDays: rangeDays)

        if let filter = episodeFilter {
            all = all.filter { $0.kind == filter }
        }

        filteredEpisodes = all
    }

    func setEpisodeFilter(_ kind: SymptomKind?) {
        episodeFilter = kind
        refreshEpisodes()
    }

    func setRangeDays(_ days: Int) {
        rangeDays = days
        refreshEpisodes()
    }

    private var pendingUndoEpisode: SymptomEpisode?

    func deleteEpisode(_ episode: SymptomEpisode) {
        pendingUndoEpisode = episode
        GroveStorage.shared.removeEpisode(id: episode.id)
        refreshEpisodes()
        toastText = "Episode removed"
        showUndoEpisodeToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, self.showUndoEpisodeToast else { return }
            self.pendingUndoEpisode = nil
            self.showUndoEpisodeToast = false
            self.toastText = nil
        }
    }

    func undoEpisodeDelete() {
        guard let episode = pendingUndoEpisode else { return }
        GroveStorage.shared.saveEpisode(episode)
        pendingUndoEpisode = nil
        showUndoEpisodeToast = false
        toastText = nil
        refreshEpisodes()
        showToast("Episode restored")
    }

    // MARK: - Episode Quick Stats

    var episodeKindCounts: [(kind: SymptomKind, count: Int)] {
        let grouped = Dictionary(grouping: filteredEpisodes, by: { $0.kind })
        return grouped.map { (kind: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var totalEpisodesInRange: Int {
        filteredEpisodes.count
    }

    // MARK: - Date Helpers

    var selectedDateFormatted: String {
        guard let date = selectedDateKey.dateFromWellnessKey else { return selectedDateKey }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    var isSelectedToday: Bool {
        selectedDateKey == Date().wellnessDateKey
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

// MARK: - CalendarDayCell

struct CalendarDayCell: Identifiable, Equatable {
    let id = UUID()
    let dateKey: String
    let dayNumber: Int
    let weekdayLabel: String   // "MON", "TUE"
    let hasLog: Bool
    let episodeCount: Int
    let isToday: Bool
    let isSelected: Bool
}

// MARK: - Range Presets

enum ChronicleRange: Int, CaseIterable, Identifiable {
    case week     = 7
    case twoWeeks = 14
    case month    = 30

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .week:     return "7 days"
        case .twoWeeks: return "14 days"
        case .month:    return "30 days"
        }
    }
}
