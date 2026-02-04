//
//  DailyTrace.swift
//  DAYTRACE
//
//  Core data model for daily tracking
//

import Foundation

struct DailyTrace: Codable {
    let id: UUID
    let date: Date
    var actions: [TraceAction]
    var mood: MoodState
    
    init(id: UUID = UUID(), date: Date = Date(), actions: [TraceAction] = [], mood: MoodState = .neutral) {
        self.id = id
        self.date = date
        self.actions = actions
        self.mood = mood
    }
}

struct TraceAction: Codable {
    let id: UUID
    var text: String
    var state: ActionState
    var category: ActionCategory
    var priority: ActionPriority
    var estimatedMinutes: Int?
    var notes: String?
    var tags: [String]
    var emotion: ActionEmotion?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        text: String,
        state: ActionState = .pending,
        category: ActionCategory = .personal,
        priority: ActionPriority = .medium,
        estimatedMinutes: Int? = nil,
        notes: String? = nil,
        tags: [String] = [],
        emotion: ActionEmotion? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.state = state
        self.category = category
        self.priority = priority
        self.estimatedMinutes = estimatedMinutes
        self.notes = notes
        self.tags = tags
        self.emotion = emotion
        self.createdAt = createdAt
    }
}

enum ActionState: String, Codable {
    case pending
    case done
    case skipped
}

enum ActionCategory: String, Codable, CaseIterable {
    case work = "Work"
    case health = "Health"
    case learning = "Learning"
    case personal = "Personal"
    case social = "Social"
    case creative = "Creative"
    case finance = "Finance"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .work: return "💼"
        case .health: return "💪"
        case .learning: return "📚"
        case .personal: return "✨"
        case .social: return "👥"
        case .creative: return "🎨"
        case .finance: return "💰"
        case .other: return "📌"
        }
    }
    
    var color: String {
        switch self {
        case .work: return "#3B82F6"      // Blue
        case .health: return "#10B981"    // Green
        case .learning: return "#8B5CF6"  // Purple
        case .personal: return "#F59E0B"  // Amber
        case .social: return "#EC4899"    // Pink
        case .creative: return "#F97316"  // Orange
        case .finance: return "#14B8A6"   // Teal
        case .other: return "#6B7280"     // Gray
        }
    }
}

enum ActionPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🔴"
        }
    }
}

enum ActionEmotion: String, Codable, CaseIterable {
    case excited = "Excited"
    case motivated = "Motivated"
    case calm = "Calm"
    case focused = "Focused"
    case tired = "Tired"
    case stressed = "Stressed"
    
    var emoji: String {
        switch self {
        case .excited: return "🤩"
        case .motivated: return "💪"
        case .calm: return "😌"
        case .focused: return "🎯"
        case .tired: return "😴"
        case .stressed: return "😰"
        }
    }
}

enum MoodState: String, Codable {
    case low
    case neutral
    case high
}
