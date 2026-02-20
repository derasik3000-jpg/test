import Foundation

// MARK: - Pet Species

enum CreatureKind: String, Codable, CaseIterable, Identifiable {
    case dog = "dog"
    case cat = "cat"
    case bird = "bird"
    case rabbit = "rabbit"
    case hamster = "hamster"
    case reptile = "reptile"
    case fish = "fish"
    case other = "other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dog:     return "🐕"
        case .cat:     return "🐈"
        case .bird:    return "🐦"
        case .rabbit:  return "🐇"
        case .hamster: return "🐹"
        case .reptile: return "🦎"
        case .fish:    return "🐠"
        case .other:   return "🐾"
        }
    }

    var displayName: String {
        switch self {
        case .dog:     return "Dog"
        case .cat:     return "Cat"
        case .bird:    return "Bird"
        case .rabbit:  return "Rabbit"
        case .hamster: return "Hamster"
        case .reptile: return "Reptile"
        case .fish:    return "Fish"
        case .other:   return "Other"
        }
    }
}

// MARK: - Pet Profile

struct CompanionProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var species: CreatureKind
    var birthText: String          // free-form: "2 years" or "2022-03-15"
    var weightKg: Double?
    var quirks: [String]           // allergies, diet notes, etc.
    var avatarEmoji: String        // emoji avatar
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        species: CreatureKind,
        birthText: String = "",
        weightKg: Double? = nil,
        quirks: [String] = [],
        avatarEmoji: String = "🐾",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.birthText = birthText
        self.weightKg = weightKg
        self.quirks = quirks
        self.avatarEmoji = avatarEmoji
        self.createdAt = createdAt
    }
}

// MARK: - Wellness Scales (1–5)

enum WellnessAxis: String, Codable, CaseIterable, Identifiable {
    case appetite   = "appetite"
    case digestion  = "digestion"
    case energy     = "energy"
    case mood       = "mood"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .appetite:  return "fork.knife"
        case .digestion: return "leaf.fill"
        case .energy:    return "bolt.fill"
        case .mood:      return "face.smiling.inverse"
        }
    }

    var displayName: String {
        switch self {
        case .appetite:  return "Appetite"
        case .digestion: return "Digestion"
        case .energy:    return "Energy"
        case .mood:      return "Mood"
        }
    }

    /// Neutral label hints for each scale level (1–5)
    var levelHints: [String] {
        switch self {
        case .appetite:
            return ["Refused", "Very low", "Moderate", "Good", "Excellent"]
        case .digestion:
            return ["Troubled", "Irregular", "Fair", "Normal", "Perfect"]
        case .energy:
            return ["Lethargic", "Low", "Moderate", "Active", "Hyper"]
        case .mood:
            return ["Distressed", "Subdued", "Calm", "Happy", "Joyful"]
        }
    }

    /// Safe access to level hint; returns nil if value is out of 1...5 range (avoids array out of bounds)
    func levelHint(for value: Int) -> String? {
        guard value >= 1, value <= levelHints.count else { return nil }
        return levelHints[value - 1]
    }
}

// MARK: - Daily Wellness Log

struct DailyWellnessLog: Codable, Identifiable, Equatable {
    let id: UUID
    let companionId: UUID
    let date: String               // "yyyy-MM-dd" for easy grouping
    var scales: [String: Int]      // WellnessAxis.rawValue -> 1...5
    var dayNote: String
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        companionId: UUID,
        date: String,
        scales: [String: Int] = [:],
        dayNote: String = "",
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.companionId = companionId
        self.date = date
        self.scales = scales
        self.dayNote = dayNote
        self.loggedAt = loggedAt
    }

    func scaleValue(for axis: WellnessAxis) -> Int? {
        scales[axis.rawValue]
    }

    func scaleValue(forAxisId axisId: String) -> Int? {
        scales[axisId]
    }

    mutating func setScale(_ axis: WellnessAxis, value: Int) {
        let clamped = min(max(value, 1), 5)
        scales[axis.rawValue] = clamped
    }

    mutating func setScale(axisId: String, value: Int) {
        let clamped = min(max(value, 1), 5)
        scales[axisId] = clamped
    }
}

// MARK: - Symptom Events

enum SymptomKind: String, Codable, CaseIterable, Identifiable {
    case vomiting   = "vomiting"
    case coughing   = "coughing"
    case itching     = "itching"
    case limping     = "limping"
    case diarrhea    = "diarrhea"
    case sneezing    = "sneezing"
    case eyeIssue    = "eye_issue"
    case custom      = "custom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vomiting:  return "exclamationmark.triangle.fill"
        case .coughing:  return "lungs.fill"
        case .itching:   return "hand.raised.fingers.spread.fill"
        case .limping:   return "figure.walk"
        case .diarrhea:  return "drop.triangle.fill"
        case .sneezing:  return "nose.fill"
        case .eyeIssue:  return "eye.fill"
        case .custom:    return "star.fill"
        }
    }

    var displayName: String {
        switch self {
        case .vomiting:  return "Vomiting"
        case .coughing:  return "Coughing"
        case .itching:   return "Itching"
        case .limping:   return "Limping"
        case .diarrhea:  return "Diarrhea"
        case .sneezing:  return "Sneezing"
        case .eyeIssue:  return "Eye Issue"
        case .custom:    return "Other"
        }
    }
}

enum SeverityLevel: Int, Codable, CaseIterable, Identifiable {
    case mild     = 1
    case moderate = 2
    case severe   = 3

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .mild:     return "Mild"
        case .moderate: return "Moderate"
        case .severe:   return "Severe"
        }
    }

    var tint: String {
        switch self {
        case .mild:     return "sproutGreen"
        case .moderate: return "lifeGold"
        case .severe:   return "emberWarn"
        }
    }
}

struct SymptomEpisode: Codable, Identifiable, Equatable {
    let id: UUID
    let companionId: UUID
    var kind: SymptomKind
    var customTitle: String?       // only if kind == .custom
    var occurredAt: Date
    var severity: SeverityLevel
    var occurrenceCount: Int       // how many times in episode
    var durationMinutes: Int?
    var note: String

    init(
        id: UUID = UUID(),
        companionId: UUID,
        kind: SymptomKind,
        customTitle: String? = nil,
        occurredAt: Date = Date(),
        severity: SeverityLevel = .mild,
        occurrenceCount: Int = 1,
        durationMinutes: Int? = nil,
        note: String = ""
    ) {
        self.id = id
        self.companionId = companionId
        self.kind = kind
        self.customTitle = customTitle
        self.occurredAt = occurredAt
        self.severity = severity
        self.occurrenceCount = occurrenceCount
        self.durationMinutes = durationMinutes
        self.note = note
    }

    var displayTitle: String {
        kind == .custom ? (customTitle ?? "Other") : kind.displayName
    }
}

// MARK: - Gamification

struct VitalityProgress: Codable, Equatable {
    var totalXP: Int
    var currentStreak: Int         // consecutive days with logs
    var longestStreak: Int
    var lastLogDate: String?       // "yyyy-MM-dd"
    var unlockedBadges: [String]   // badge IDs
    var companionCount: Int
    var totalLogs: Int
    var totalEpisodes: Int

    init() {
        self.totalXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastLogDate = nil
        self.unlockedBadges = []
        self.companionCount = 0
        self.totalLogs = 0
        self.totalEpisodes = 0
    }

    // MARK: - Level Calculation

    /// XP thresholds per level (progressive)
    var currentLevel: Int {
        // Levels: 0-50 XP = 1, 50-150 = 2, 150-300 = 3, etc.
        let thresholds = [0, 50, 150, 300, 500, 800, 1200, 1800, 2500, 3500, 5000]
        for (index, threshold) in thresholds.enumerated().reversed() {
            if totalXP >= threshold { return index + 1 }
        }
        return 1
    }

    var xpForCurrentLevel: Int {
        let thresholds = [0, 50, 150, 300, 500, 800, 1200, 1800, 2500, 3500, 5000]
        let level = currentLevel
        let idx = min(level - 1, thresholds.count - 1)
        return thresholds[idx]
    }

    var xpForNextLevel: Int {
        let thresholds = [0, 50, 150, 300, 500, 800, 1200, 1800, 2500, 3500, 5000]
        let level = currentLevel
        let idx = min(level, thresholds.count - 1)
        return thresholds[idx]
    }

    var levelProgress: Double {
        let needed = xpForNextLevel - xpForCurrentLevel
        guard needed > 0 else { return 1.0 }
        let earned = totalXP - xpForCurrentLevel
        return Double(earned) / Double(needed)
    }

    var levelTitle: String {
        switch currentLevel {
        case 1:  return "Novice Observer"
        case 2:  return "Keen Watcher"
        case 3:  return "Wellness Scout"
        case 4:  return "Health Guardian"
        case 5:  return "Vital Sentinel"
        case 6:  return "Aura Keeper"
        case 7:  return "Master Tracker"
        case 8:  return "Legendary Caretaker"
        case 9:  return "Mythic Protector"
        case 10: return "Eternal Guardian"
        default: return "Transcendent"
        }
    }
}

// MARK: - Badges

enum GuardianBadge: String, CaseIterable, Identifiable {
    case firstLog        = "first_log"
    case weekWarrior     = "week_warrior"
    case tenStreak       = "ten_streak"
    case centurion       = "centurion"         // 100 logs
    case multiCompanion  = "multi_companion"   // 2+ pets
    case nightOwl        = "night_owl"         // log after 22:00
    case earlyBird       = "early_bird"        // log before 7:00
    case detailDevotee   = "detail_devotee"    // 10 events with notes
    case fullSpectrum    = "full_spectrum"      // all 4 scales in one day
    case firstEpisode    = "first_episode"
    case fiveEpisodes    = "five_episodes"
    case twentyEpisodes  = "twenty_episodes"
    case veteran         = "veteran"           // 50 episodes
    case vetVisit        = "vet_visit"
    case threeVetVisits  = "three_vet_visits"
    case vetRegular      = "vet_regular"       // 10 visits
    case reminderSet     = "reminder_set"
    case fiveReminders   = "five_reminders"
    case chronicCare     = "chronic_care"      // 10 reminders
    case monthStreak     = "month_streak"      // 30 days
    case sixtyStreak     = "sixty_streak"      // 60 days
    case guardian        = "guardian"          // 500 logs
    case dedicated       = "dedicated"         // 1000 logs
    case triCompanion    = "tri_companion"     // 3+ pets
    case weekendWarrior  = "weekend_warrior"
    case consistency     = "consistency"       // 14-day streak
    case dawnPatrol      = "dawn_patrol"       // before 6 AM
    case midnightWatcher = "midnight_watcher"  // after 11 PM
    case reminderMaster  = "reminder_master"    // 20 reminders

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .firstLog:       return "🏅"
        case .weekWarrior:    return "🔥"
        case .tenStreak:      return "⚡"
        case .centurion:      return "💯"
        case .multiCompanion: return "🐾"
        case .nightOwl:       return "🦉"
        case .earlyBird:      return "🌅"
        case .detailDevotee:  return "📝"
        case .fullSpectrum:   return "🌈"
        case .firstEpisode:   return "📋"
        case .fiveEpisodes:   return "📊"
        case .twentyEpisodes: return "📈"
        case .veteran:        return "🎖️"
        case .vetVisit:       return "🩺"
        case .threeVetVisits: return "🏥"
        case .vetRegular:     return "👨‍⚕️"
        case .reminderSet:    return "🔔"
        case .fiveReminders:  return "⏰"
        case .chronicCare:    return "💊"
        case .monthStreak:    return "📆"
        case .sixtyStreak:    return "🗓️"
        case .guardian:       return "🛡️"
        case .dedicated:      return "💎"
        case .triCompanion:   return "🐕‍🦺"
        case .weekendWarrior: return "☀️"
        case .consistency:    return "📌"
        case .dawnPatrol:     return "🌄"
        case .midnightWatcher: return "🌙"
        case .reminderMaster: return "🎯"
        }
    }

    var displayName: String {
        switch self {
        case .firstLog:       return "First Step"
        case .weekWarrior:    return "Week Warrior"
        case .tenStreak:      return "Ten Streak"
        case .centurion:      return "Centurion"
        case .multiCompanion: return "Pack Leader"
        case .nightOwl:       return "Night Owl"
        case .earlyBird:      return "Early Bird"
        case .detailDevotee:  return "Detail Devotee"
        case .fullSpectrum:   return "Full Spectrum"
        case .firstEpisode:   return "First Report"
        case .fiveEpisodes:   return "Tracker"
        case .twentyEpisodes: return "Vigilant"
        case .veteran:        return "Veteran"
        case .vetVisit:       return "First Visit"
        case .threeVetVisits: return "Regular Check"
        case .vetRegular:     return "Vet Regular"
        case .reminderSet:    return "Care Starter"
        case .fiveReminders:  return "Organized"
        case .chronicCare:    return "Chronic Care"
        case .monthStreak:    return "Month Warrior"
        case .sixtyStreak:    return "Sixty Days"
        case .guardian:       return "Guardian"
        case .dedicated:      return "Dedicated"
        case .triCompanion:   return "Full Pack"
        case .weekendWarrior: return "Weekend Warrior"
        case .consistency:    return "Consistency"
        case .dawnPatrol:     return "Dawn Patrol"
        case .midnightWatcher: return "Midnight Watcher"
        case .reminderMaster: return "Reminder Master"
        }
    }

    var requirement: String {
        switch self {
        case .firstLog:       return "Log your first observation"
        case .weekWarrior:    return "7-day logging streak"
        case .tenStreak:      return "10-day logging streak"
        case .centurion:      return "Record 100 daily logs"
        case .multiCompanion: return "Add 2 or more companions"
        case .nightOwl:       return "Log after 10 PM"
        case .earlyBird:      return "Log before 7 AM"
        case .detailDevotee:  return "Add notes to 10 events"
        case .fullSpectrum:   return "Rate all 4 scales in one day"
        case .firstEpisode:   return "Log first symptom"
        case .fiveEpisodes:   return "Log 5 episodes"
        case .twentyEpisodes: return "Log 20 episodes"
        case .veteran:        return "Log 50 episodes"
        case .vetVisit:       return "Log first vet visit"
        case .threeVetVisits: return "Log 3 vet visits"
        case .vetRegular:     return "Log 10 vet visits"
        case .reminderSet:    return "Create first reminder"
        case .fiveReminders:  return "Create 5 reminders"
        case .chronicCare:    return "Create 10 reminders"
        case .monthStreak:    return "30-day logging streak"
        case .sixtyStreak:    return "60-day logging streak"
        case .guardian:       return "Record 500 daily logs"
        case .dedicated:      return "Record 1000 daily logs"
        case .triCompanion:   return "Add 3 or more companions"
        case .weekendWarrior: return "Log on weekend"
        case .consistency:    return "14-day logging streak"
        case .dawnPatrol:     return "Log before 6 AM"
        case .midnightWatcher: return "Log after 11 PM"
        case .reminderMaster: return "Create 20 reminders"
        }
    }
}

// MARK: - XP Rewards

enum XPReward {
    static let dailyLog       = 10    // logging any scale
    static let fullDayLog     = 20    // all 4 scales in a day
    static let symptomReport  = 15    // adding a symptom event
    static let noteAdded      = 5     // adding day note or event note
    static let streakBonus    = 5     // per streak day multiplier cap at 25
    static let badgeUnlock    = 50    // bonus for unlocking a badge
}

// MARK: - Date Helpers

extension Date {
    var wellnessDateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension String {
    var dateFromWellnessKey: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}
