import Foundation

public enum KrynexType: Int16, Identifiable, CaseIterable {
    case putt = 0
    case chip = 1
    case drive = 2
    
    public var id: Int16 { rawValue }
    
    public var vyloxName: String {
        switch self {
        case .putt: return "Putting"
        case .chip: return "Chip"
        case .drive: return "Drive"
        }
    }
    
    public var qyrixIcon: String {
        switch self {
        case .putt: return "smallcircle.filled.circle"
        case .chip: return "arrowtriangle.up.circle"
        case .drive: return "flag.checkered"
        }
    }
}

public enum ZylexAttemptKind: Int16, Identifiable {
    case puttHit = 0
    case puttMiss = 1
    case chipZone = 10
    case chipOut = 11
    case driveFairway = 20
    case driveRough = 21
    case driveOB = 22
    
    public var id: Int16 { rawValue }
}

public enum HexorAttemptLabel: Int16 {
    case short = 0
    case long = 1
    case left = 2
    case right = 3
    case slice = 4
    case hook = 5
    
    public var nyxelText: String {
        switch self {
        case .short: return "Short"
        case .long: return "Long"
        case .left: return "Left"
        case .right: return "Right"
        case .slice: return "Slice"
        case .hook: return "Hook"
        }
    }
}

public struct ZaxorTemplateDTO: Identifiable, Equatable {
    public let id: UUID
    public let type: KrynexType
    public let name: String
    public let defaultDurationMin: Int
    public let defaultTargetAttempts: Int
    
    public init(id: UUID, type: KrynexType, name: String, defaultDurationMin: Int, defaultTargetAttempts: Int) {
        self.id = id
        self.type = type
        self.name = name
        self.defaultDurationMin = defaultDurationMin
        self.defaultTargetAttempts = defaultTargetAttempts
    }
}

public struct QuixoSessionDTO: Identifiable, Equatable {
    public let id: UUID
    public let status: Int
    public let startedAt: Date
    public let finishedAt: Date?
    public let autoAdvance: Bool
    public let moodRating: Int
    
    public init(id: UUID, status: Int, startedAt: Date, finishedAt: Date?, autoAdvance: Bool, moodRating: Int = 0) {
        self.id = id
        self.status = status
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.autoAdvance = autoAdvance
        self.moodRating = moodRating
    }
}

public struct VexitRunDTO: Identifiable, Equatable {
    public let id: UUID
    public let sessionId: UUID
    public let orderIndex: Int
    public let type: KrynexType
    public let durationMin: Int
    public let targetAttempts: Int
    public let startedAt: Date?
    public let finishedAt: Date?
    public let actualDurationSec: Int
    public let attemptsTotal: Int
    public let successCount: Int
    public let conversionPct: Double?
    public let pacePerMin: Double?
    
    public init(id: UUID, sessionId: UUID, orderIndex: Int, type: KrynexType, durationMin: Int, targetAttempts: Int, startedAt: Date?, finishedAt: Date?, actualDurationSec: Int, attemptsTotal: Int, successCount: Int, conversionPct: Double?, pacePerMin: Double?) {
        self.id = id
        self.sessionId = sessionId
        self.orderIndex = orderIndex
        self.type = type
        self.durationMin = durationMin
        self.targetAttempts = targetAttempts
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.actualDurationSec = actualDurationSec
        self.attemptsTotal = attemptsTotal
        self.successCount = successCount
        self.conversionPct = conversionPct
        self.pacePerMin = pacePerMin
    }
}

public struct RyxelAttemptDTO: Identifiable, Equatable {
    public let id: UUID
    public let blockRunId: UUID
    public let timestamp: Date
    public let kind: ZylexAttemptKind
    public let label: HexorAttemptLabel?
    
    public init(id: UUID, blockRunId: UUID, timestamp: Date, kind: ZylexAttemptKind, label: HexorAttemptLabel?) {
        self.id = id
        self.blockRunId = blockRunId
        self.timestamp = timestamp
        self.kind = kind
        self.label = label
    }
}

public struct NyxelSettingsDTO: Identifiable, Equatable {
    public let id: UUID
    public let hapticsEnabled: Bool
    public let endBeepEnabled: Bool
    public let defaultTargets: [KrynexType: Int]
    public let onboardingCompleted: Bool
    public let notificationsEnabled: Bool
    public let notificationHour: Int
    public let notificationMinute: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let lastTrainingDate: Date?
    public let weeklyGoalAttempts: Int
    public let weeklyProgressAttempts: Int
    public let weekStartDate: Date?
    public let unlockedBadges: Set<String>
    
    public init(
        id: UUID,
        hapticsEnabled: Bool,
        endBeepEnabled: Bool,
        defaultTargets: [KrynexType: Int],
        onboardingCompleted: Bool,
        notificationsEnabled: Bool = false,
        notificationHour: Int = 9,
        notificationMinute: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastTrainingDate: Date? = nil,
        weeklyGoalAttempts: Int = 500,
        weeklyProgressAttempts: Int = 0,
        weekStartDate: Date? = nil,
        unlockedBadges: Set<String> = []
    ) {
        self.id = id
        self.hapticsEnabled = hapticsEnabled
        self.endBeepEnabled = endBeepEnabled
        self.defaultTargets = defaultTargets
        self.onboardingCompleted = onboardingCompleted
        self.notificationsEnabled = notificationsEnabled
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastTrainingDate = lastTrainingDate
        self.weeklyGoalAttempts = weeklyGoalAttempts
        self.weeklyProgressAttempts = weeklyProgressAttempts
        self.weekStartDate = weekStartDate
        self.unlockedBadges = unlockedBadges
    }
}

public enum ZylorBadgeType: String, CaseIterable, Identifiable {
    case firstSession = "first_session"
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case reps100 = "reps_100"
    case reps500 = "reps_500"
    case reps1000 = "reps_1000"
    case reps5000 = "reps_5000"
    case accuracy70 = "accuracy_70"
    case accuracy80 = "accuracy_80"
    case accuracy90 = "accuracy_90"
    case weeklyChamp = "weekly_champ"
    case perfectBlock = "perfect_block"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    
    public var id: String { rawValue }
    
    public var qyrexIcon: String {
        switch self {
        case .firstSession: return "star.fill"
        case .streak3: return "flame"
        case .streak7: return "flame.fill"
        case .streak30: return "flame.circle.fill"
        case .reps100: return "figure.golf"
        case .reps500: return "medal"
        case .reps1000: return "medal.fill"
        case .reps5000: return "crown"
        case .accuracy70: return "target"
        case .accuracy80: return "scope"
        case .accuracy90: return "bullseye"
        case .weeklyChamp: return "trophy"
        case .perfectBlock: return "checkmark.seal.fill"
        case .earlyBird: return "sun.horizon.fill"
        case .nightOwl: return "moon.stars.fill"
        }
    }
    
    public var vyloxTitle: String {
        switch self {
        case .firstSession: return "First Swing"
        case .streak3: return "Warming Up"
        case .streak7: return "On Fire"
        case .streak30: return "Unstoppable"
        case .reps100: return "Beginner"
        case .reps500: return "Dedicated"
        case .reps1000: return "Committed"
        case .reps5000: return "Master"
        case .accuracy70: return "Sharp Eye"
        case .accuracy80: return "Precision"
        case .accuracy90: return "Sniper"
        case .weeklyChamp: return "Weekly Champ"
        case .perfectBlock: return "Flawless"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        }
    }
    
    public var hyrexDescription: String {
        switch self {
        case .firstSession: return "Complete your first session"
        case .streak3: return "Train 3 days in a row"
        case .streak7: return "Train 7 days in a row"
        case .streak30: return "Train 30 days in a row"
        case .reps100: return "Complete 100 total reps"
        case .reps500: return "Complete 500 total reps"
        case .reps1000: return "Complete 1000 total reps"
        case .reps5000: return "Complete 5000 total reps"
        case .accuracy70: return "Achieve 70% accuracy in a block"
        case .accuracy80: return "Achieve 80% accuracy in a block"
        case .accuracy90: return "Achieve 90% accuracy in a block"
        case .weeklyChamp: return "Complete weekly challenge"
        case .perfectBlock: return "100% accuracy in a block"
        case .earlyBird: return "Train before 8 AM"
        case .nightOwl: return "Train after 10 PM"
        }
    }
}

public enum VyraxMoodLevel: Int, CaseIterable, Identifiable {
    case exhausted = 1
    case tired = 2
    case neutral = 3
    case energized = 4
    case excellent = 5
    
    public var id: Int { rawValue }
    
    public var qyrexEmoji: String {
        switch self {
        case .exhausted: return "😫"
        case .tired: return "😐"
        case .neutral: return "🙂"
        case .energized: return "😊"
        case .excellent: return "🔥"
        }
    }
    
    public var vyloxLabel: String {
        switch self {
        case .exhausted: return "Worn Out"
        case .tired: return "Fatigued"
        case .neutral: return "Balanced"
        case .energized: return "Strong"
        case .excellent: return "Peak Form"
        }
    }
}

