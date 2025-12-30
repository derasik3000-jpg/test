import Foundation

struct RitualStepDTO {
    let id: UUID
    let title: String
    let desc: String?
    let iconName: String
    let orderIndex: Int
    let isArchived: Bool
}

struct DayStepDTO {
    let id: UUID
    let title: String
    let iconName: String
    let orderIndex: Int
    let isDone: Bool
    let timestamp: Date?
}

struct TagDTO {
    let id: UUID
    let name: String
    let isArchived: Bool
}

struct DayDTO {
    let id: UUID
    let date: Date
    let sleepStart: (h: Int, m: Int)
    let sleepEnd: (h: Int, m: Int)
    let rating: Int
    let note: String?
    let steps: [DayStepDTO]
    let tags: [TagDTO]
}

struct SettingsDTO {
    let defSleepStart: (h: Int, m: Int)
    let defSleepEnd: (h: Int, m: Int)
    let hapticsEnabled: Bool
}

struct WeekPointDTO {
    let date: Date
    let ratio: Double
    let isCalm: Bool
}

struct StepPoint {
    let title: String
    let iconName: String
    let orderIndex: Int
    let isDone: Bool
    let timestamp: Date?
}

