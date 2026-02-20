import Foundation

// MARK: - GroveStorage
// Local JSON file persistence — no Core Data, no cloud
// Each data type stored in its own .json file in Documents
// Thread-safe: all read/write goes through serial queue

final class GroveStorage {

    static let shared = GroveStorage()

    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let queue = DispatchQueue(label: "com.pawvital.grovestorage", qos: .userInitiated)

    // File names
    private let companionsFile   = "companions.json"
    private let wellnessLogsFile = "wellness_logs.json"
    private let episodesFile     = "symptom_episodes.json"
    private let careRemindersFile = "care_reminders.json"
    private let vetVisitsFile    = "vet_visits.json"
    private let progressFile     = "vitality_progress.json"
    private let settingsFile     = "sanctuary_settings.json"
    private let onboardingFile   = "onboarding_state.json"

    // In-memory cache (internal; use accessors for thread-safe read)
    private var _companions: [CompanionProfile] = []
    private var _wellnessLogs: [DailyWellnessLog] = []
    private var _episodes: [SymptomEpisode] = []
    private var _careReminders: [CareReminder] = []
    private var _vetVisits: [VetVisit] = []
    private var _progress: VitalityProgress = VitalityProgress()
    private var _settings: SanctuarySettings = SanctuarySettings()
    private var _onboarding: OnboardingState = OnboardingState()

    var companions: [CompanionProfile] { queue.sync { _companions } }
    var wellnessLogs: [DailyWellnessLog] { queue.sync { _wellnessLogs } }
    var episodes: [SymptomEpisode] { queue.sync { _episodes } }
    var careReminders: [CareReminder] { queue.sync { _careReminders } }
    var vetVisits: [VetVisit] { queue.sync { _vetVisits } }
    var progress: VitalityProgress { queue.sync { _progress } }
    var settings: SanctuarySettings { queue.sync { _settings } }
    var onboarding: OnboardingState { queue.sync { _onboarding } }

    // MARK: - Init

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        loadAll()
    }

    // MARK: - Directory

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func fileURL(for name: String) -> URL {
        documentsURL.appendingPathComponent(name)
    }

    // MARK: - Generic Read / Write (corrupt-safe)

    private func load<T: Decodable>(_ type: T.Type, from fileName: String) -> T? {
        let url = fileURL(for: fileName)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("⚠️ GroveStorage: corrupt or invalid \(fileName) — \(error.localizedDescription). Resetting to default.")
            try? fileManager.removeItem(at: url)
            return nil
        }
    }

    private func save<T: Encodable>(_ value: T, to fileName: String) {
        let url = fileURL(for: fileName)
        do {
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("⚠️ GroveStorage: failed to save \(fileName) — \(error.localizedDescription)")
        }
    }

    // MARK: - Load All

    private func loadAll() {
        queue.sync {
            _companions    = load([CompanionProfile].self, from: companionsFile) ?? []
            _wellnessLogs  = load([DailyWellnessLog].self, from: wellnessLogsFile) ?? []
            _episodes      = load([SymptomEpisode].self, from: episodesFile) ?? []
            _careReminders = load([CareReminder].self, from: careRemindersFile) ?? []
            _vetVisits     = load([VetVisit].self, from: vetVisitsFile) ?? []
            _progress      = load(VitalityProgress.self, from: progressFile) ?? VitalityProgress()
            _settings      = load(SanctuarySettings.self, from: settingsFile) ?? SanctuarySettings()
            _onboarding    = load(OnboardingState.self, from: onboardingFile) ?? OnboardingState()
        }
    }

    // MARK: - Companions

    func saveCompanion(_ companion: CompanionProfile) {
        queue.sync {
            if let index = _companions.firstIndex(where: { $0.id == companion.id }) {
                _companions[index] = companion
            } else {
                _companions.append(companion)
            }
            save(_companions, to: companionsFile)
            recountCompanions()
        }
    }

    func removeCompanion(id: UUID) {
        queue.sync {
            _companions.removeAll { $0.id == id }
            _wellnessLogs.removeAll { $0.companionId == id }
            _episodes.removeAll { $0.companionId == id }
            _careReminders.removeAll { $0.companionId == id }
            _vetVisits.removeAll { $0.companionId == id }
            save(_companions, to: companionsFile)
            save(_wellnessLogs, to: wellnessLogsFile)
            save(_episodes, to: episodesFile)
            save(_careReminders, to: careRemindersFile)
            save(_vetVisits, to: vetVisitsFile)
            recountCompanions()
        }
    }

    // MARK: - Wellness Logs

    func wellnessLog(for companionId: UUID, dateKey: String) -> DailyWellnessLog? {
        queue.sync {
            _wellnessLogs.first { $0.companionId == companionId && $0.date == dateKey }
        }
    }

    func saveWellnessLog(_ log: DailyWellnessLog) {
        queue.sync {
            if let index = _wellnessLogs.firstIndex(where: { $0.id == log.id }) {
                _wellnessLogs[index] = log
            } else {
                _wellnessLogs.append(log)
            }
            save(_wellnessLogs, to: wellnessLogsFile)
            updateProgressAfterLog(log)
        }
    }

    func logsForCompanion(_ companionId: UUID, lastDays: Int = 7) -> [DailyWellnessLog] {
        queue.sync {
            let calendar = Calendar.current
            let cutoff = calendar.date(byAdding: .day, value: -lastDays, to: Date()) ?? Date()
            let cutoffKey = cutoff.wellnessDateKey
            return _wellnessLogs
                .filter { $0.companionId == companionId && $0.date >= cutoffKey }
                .sorted { $0.date < $1.date }
        }
    }

    func allLogsForCompanion(_ companionId: UUID) -> [DailyWellnessLog] {
        queue.sync {
            _wellnessLogs
                .filter { $0.companionId == companionId }
                .sorted { $0.date < $1.date }
        }
    }

    // MARK: - Symptom Episodes

    func saveEpisode(_ episode: SymptomEpisode) {
        queue.sync {
            if let index = _episodes.firstIndex(where: { $0.id == episode.id }) {
                _episodes[index] = episode
            } else {
                _episodes.append(episode)
            }
            save(_episodes, to: episodesFile)
            updateProgressAfterEpisode(episode)
        }
    }

    func removeEpisode(id: UUID) {
        queue.sync {
            _episodes.removeAll { $0.id == id }
            save(_episodes, to: episodesFile)
        }
    }

    func episodesForCompanion(_ companionId: UUID, lastDays: Int = 7) -> [SymptomEpisode] {
        queue.sync {
            let calendar = Calendar.current
            let cutoff = calendar.date(byAdding: .day, value: -lastDays, to: Date()) ?? Date()
            return _episodes
                .filter { $0.companionId == companionId && $0.occurredAt >= cutoff }
                .sorted { $0.occurredAt > $1.occurredAt }
        }
    }

    func allEpisodesForCompanion(_ companionId: UUID) -> [SymptomEpisode] {
        queue.sync {
            _episodes
                .filter { $0.companionId == companionId }
                .sorted { $0.occurredAt > $1.occurredAt }
        }
    }

    // MARK: - Care Reminders

    func saveCareReminder(_ reminder: CareReminder) {
        queue.sync {
            if let index = _careReminders.firstIndex(where: { $0.id == reminder.id }) {
                _careReminders[index] = reminder
            } else {
                _careReminders.append(reminder)
            }
            save(_careReminders, to: careRemindersFile)
            updateProgressAfterCareReminder()
            ReminderNotificationScheduler.shared.schedule(reminder)
        }
    }

    func removeCareReminder(id: UUID) {
        queue.sync {
            _careReminders.removeAll { $0.id == id }
            save(_careReminders, to: careRemindersFile)
            ReminderNotificationScheduler.shared.cancel(reminderId: id)
        }
    }

    func remindersFor(date: Date, companionId: UUID?) -> [CareReminder] {
        queue.sync {
            _careReminders
                .filter { $0.appliesTo(date: date) }
                .filter { $0.companionId == nil || $0.companionId == companionId }
                .sorted { $0.dueDate < $1.dueDate }
        }
    }

    func dateKeysWithReminders(month: Date, companionId: UUID?) -> Set<String> {
        queue.sync {
            let cal = Calendar.current
            guard let range = cal.range(of: .day, in: .month, for: month),
                  let start = cal.date(from: cal.dateComponents([.year, .month], from: month)) else { return [] }
            var keys = Set<String>()
            for dayOffset in range {
                guard let date = cal.date(byAdding: .day, value: dayOffset - 1, to: start) else { continue }
                let hasReminder = _careReminders.contains { $0.appliesTo(date: date) && ($0.companionId == nil || $0.companionId == companionId) }
                if hasReminder { keys.insert(date.wellnessDateKey) }
            }
            return keys
        }
    }

    // MARK: - Vet Visits

    func saveVetVisit(_ visit: VetVisit) {
        queue.sync {
            if let index = _vetVisits.firstIndex(where: { $0.id == visit.id }) {
                _vetVisits[index] = visit
            } else {
                _vetVisits.append(visit)
            }
            save(_vetVisits, to: vetVisitsFile)
            updateProgressAfterVetVisit()
        }
    }

    func removeVetVisit(id: UUID) {
        queue.sync {
            _vetVisits.removeAll { $0.id == id }
            save(_vetVisits, to: vetVisitsFile)
        }
    }

    func vetVisitsFor(date: Date, companionId: UUID?) -> [VetVisit] {
        queue.sync {
            let key = date.wellnessDateKey
            return _vetVisits
                .filter { $0.date.wellnessDateKey == key }
                .filter { companionId == nil || $0.companionId == companionId }
                .sorted { $0.date < $1.date }
        }
    }

    func dateKeysWithVetVisits(month: Date, companionId: UUID?) -> Set<String> {
        queue.sync {
            let cal = Calendar.current
            guard let range = cal.range(of: .day, in: .month, for: month),
                  let start = cal.date(from: cal.dateComponents([.year, .month], from: month)) else { return [] }
            var keys = Set<String>()
            for dayOffset in range {
                guard let date = cal.date(byAdding: .day, value: dayOffset - 1, to: start) else { continue }
                let key = date.wellnessDateKey
                let hasVisit = _vetVisits.contains { $0.date.wellnessDateKey == key && (companionId == nil || $0.companionId == companionId) }
                if hasVisit { keys.insert(key) }
            }
            return keys
        }
    }

    // MARK: - Gamification Progress

    private func updateProgressAfterLog(_ log: DailyWellnessLog) {
        let today = Date().wellnessDateKey

        // XP for logging
        let filledScales = log.scales.values.filter { $0 > 0 }.count
        if filledScales > 0 {
            _progress.totalXP += XPReward.dailyLog
        }
        let totalAxes = _settings.enabledAxes.count
        if totalAxes > 0 && filledScales >= totalAxes {
            _progress.totalXP += XPReward.fullDayLog
            unlockBadgeIfNeeded(.fullSpectrum)
        }
        if !log.dayNote.isEmpty {
            _progress.totalXP += XPReward.noteAdded
        }

        // Streak
        if let lastDate = _progress.lastLogDate {
            if lastDate == today {
                // Same day — no streak change
            } else if let lastD = lastDate.dateFromWellnessKey,
                      let diff = Calendar.current.dateComponents([.day], from: lastD, to: Date()).day,
                      diff == 1 {
                _progress.currentStreak += 1
                let streakBonus = min(_progress.currentStreak * XPReward.streakBonus, 25)
                _progress.totalXP += streakBonus
            } else {
                _progress.currentStreak = 1
            }
        } else {
            _progress.currentStreak = 1
        }

        _progress.lastLogDate = today
        _progress.longestStreak = max(_progress.longestStreak, _progress.currentStreak)
        _progress.totalLogs = _wellnessLogs.count

        // Badge checks
        unlockBadgeIfNeeded(.firstLog)
        if _progress.currentStreak >= 7 { unlockBadgeIfNeeded(.weekWarrior) }
        if _progress.currentStreak >= 10 { unlockBadgeIfNeeded(.tenStreak) }
        if _progress.currentStreak >= 14 { unlockBadgeIfNeeded(.consistency) }
        if _progress.currentStreak >= 30 || _progress.longestStreak >= 30 { unlockBadgeIfNeeded(.monthStreak) }
        if _progress.currentStreak >= 60 || _progress.longestStreak >= 60 { unlockBadgeIfNeeded(.sixtyStreak) }
        if _progress.totalLogs >= 100 { unlockBadgeIfNeeded(.centurion) }
        if _progress.totalLogs >= 500 { unlockBadgeIfNeeded(.guardian) }
        if _progress.totalLogs >= 1000 { unlockBadgeIfNeeded(.dedicated) }

        // Time-based badges
        let hour = Calendar.current.component(.hour, from: Date())
        let weekday = Calendar.current.component(.weekday, from: Date()) // 1=Sun, 7=Sat
        if hour >= 22 || hour < 4 { unlockBadgeIfNeeded(.nightOwl) }
        if hour >= 23 || hour < 1 { unlockBadgeIfNeeded(.midnightWatcher) }
        if hour >= 4 && hour < 7 { unlockBadgeIfNeeded(.earlyBird) }
        if hour >= 4 && hour < 6 { unlockBadgeIfNeeded(.dawnPatrol) }
        if weekday == 1 || weekday == 7 { unlockBadgeIfNeeded(.weekendWarrior) }

        save(_progress, to: progressFile)
    }

    private func updateProgressAfterEpisode(_ episode: SymptomEpisode) {
        _progress.totalXP += XPReward.symptomReport
        if !episode.note.isEmpty {
            _progress.totalXP += XPReward.noteAdded
        }
        _progress.totalEpisodes = _episodes.count

        // Detail Devotee badge
        let notedEpisodes = _episodes.filter { !$0.note.isEmpty }.count
        if notedEpisodes >= 10 { unlockBadgeIfNeeded(.detailDevotee) }

        // Episode badges
        if _progress.totalEpisodes >= 1 { unlockBadgeIfNeeded(.firstEpisode) }
        if _progress.totalEpisodes >= 5 { unlockBadgeIfNeeded(.fiveEpisodes) }
        if _progress.totalEpisodes >= 20 { unlockBadgeIfNeeded(.twentyEpisodes) }
        if _progress.totalEpisodes >= 50 { unlockBadgeIfNeeded(.veteran) }

        save(_progress, to: progressFile)
    }

    private func recountCompanions() {
        _progress.companionCount = _companions.count
        if _companions.count >= 2 { unlockBadgeIfNeeded(.multiCompanion) }
        if _companions.count >= 3 { unlockBadgeIfNeeded(.triCompanion) }
        save(_progress, to: progressFile)
    }

    private func updateProgressAfterVetVisit() {
        let count = _vetVisits.count
        if count >= 1 { unlockBadgeIfNeeded(.vetVisit) }
        if count >= 3 { unlockBadgeIfNeeded(.threeVetVisits) }
        if count >= 10 { unlockBadgeIfNeeded(.vetRegular) }
        save(_progress, to: progressFile)
    }

    private func updateProgressAfterCareReminder() {
        let count = _careReminders.count
        if count >= 1 { unlockBadgeIfNeeded(.reminderSet) }
        if count >= 5 { unlockBadgeIfNeeded(.fiveReminders) }
        if count >= 10 { unlockBadgeIfNeeded(.chronicCare) }
        if count >= 20 { unlockBadgeIfNeeded(.reminderMaster) }
        save(_progress, to: progressFile)
    }

    private func unlockBadgeIfNeeded(_ badge: GuardianBadge) {
        guard !_progress.unlockedBadges.contains(badge.rawValue) else { return }
        _progress.unlockedBadges.append(badge.rawValue)
        _progress.totalXP += XPReward.badgeUnlock
    }

    // MARK: - Settings

    func saveSettings(_ newSettings: SanctuarySettings) {
        queue.sync {
            _settings = newSettings
            save(_settings, to: settingsFile)
        }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        queue.sync {
            _onboarding.hasCompletedOnboarding = true
            save(_onboarding, to: onboardingFile)
        }
    }

    func markCoachSeen() {
        queue.sync {
            _onboarding.hasSeenCoachMarks = true
            save(_onboarding, to: onboardingFile)
        }
    }

    // MARK: - Reset (danger zone)

    func purgeAllData() {
        queue.sync {
            _companions = []
            _wellnessLogs = []
            _episodes = []
            _careReminders = []
            _vetVisits = []
            _progress = VitalityProgress()
            _settings = SanctuarySettings()
            _onboarding = OnboardingState()

            let files = [companionsFile, wellnessLogsFile, episodesFile,
                         careRemindersFile, vetVisitsFile,
                         progressFile, settingsFile, onboardingFile]
            for file in files {
                try? fileManager.removeItem(at: fileURL(for: file))
            }
        }
    }
}

// MARK: - Custom Wellness Axis (user-added scale for Today's Check-in)

struct CustomWellnessAxis: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var icon: String      // SF Symbol name

    var rawValue: String { "custom_\(id)" }
}

// MARK: - Custom Reminder Kind (user-added category for Add Reminder)

struct CustomReminderKind: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var icon: String      // SF Symbol name

    var kindId: String { "custom_\(id)" }
}

// MARK: - Settings Model

struct SanctuarySettings: Codable, Equatable {
    var enabledAxes: [String]         // WellnessAxis rawValues + custom rawValues
    var insightsEnabled: Bool
    var defaultRangeDays: Int
    var userAvatarEmoji: String       // user's own avatar
    var customWellnessAxes: [CustomWellnessAxis]
    var customReminderKinds: [CustomReminderKind]

    init(
        enabledAxes: [String] = WellnessAxis.allCases.map(\.rawValue),
        insightsEnabled: Bool = true,
        defaultRangeDays: Int = 7,
        userAvatarEmoji: String = "😊",
        customWellnessAxes: [CustomWellnessAxis] = [],
        customReminderKinds: [CustomReminderKind] = []
    ) {
        self.enabledAxes = enabledAxes
        self.insightsEnabled = insightsEnabled
        self.defaultRangeDays = defaultRangeDays
        self.userAvatarEmoji = userAvatarEmoji
        self.customWellnessAxes = customWellnessAxes
        self.customReminderKinds = customReminderKinds
    }

    var activeAxes: [WellnessAxis] {
        enabledAxes.compactMap { WellnessAxis(rawValue: $0) }
    }

    var activeCustomAxes: [CustomWellnessAxis] {
        customWellnessAxes.filter { enabledAxes.contains($0.rawValue) }
    }
}

extension SanctuarySettings {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        enabledAxes = try c.decodeIfPresent([String].self, forKey: .enabledAxes) ?? WellnessAxis.allCases.map(\.rawValue)
        insightsEnabled = try c.decodeIfPresent(Bool.self, forKey: .insightsEnabled) ?? true
        defaultRangeDays = try c.decodeIfPresent(Int.self, forKey: .defaultRangeDays) ?? 7
        userAvatarEmoji = try c.decodeIfPresent(String.self, forKey: .userAvatarEmoji) ?? "😊"
        customWellnessAxes = try c.decodeIfPresent([CustomWellnessAxis].self, forKey: .customWellnessAxes) ?? []
        customReminderKinds = try c.decodeIfPresent([CustomReminderKind].self, forKey: .customReminderKinds) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case enabledAxes, insightsEnabled, defaultRangeDays, userAvatarEmoji
        case customWellnessAxes, customReminderKinds
    }
}

// MARK: - Onboarding State

struct OnboardingState: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var hasSeenCoachMarks: Bool

    init(
        hasCompletedOnboarding: Bool = false,
        hasSeenCoachMarks: Bool = false
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasSeenCoachMarks = hasSeenCoachMarks
    }
}
